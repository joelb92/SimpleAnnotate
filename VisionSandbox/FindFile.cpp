//==========================================================================
// FindFile.cpp
//
// Searches for files and folders with a variety of different options in 
// a given location
//
// Author: Louka Dlagnekov
//
// This source code is free software; you can redistribute it and/or
// modify it any way you see fit as long as this statement and the original
// author's name remains.
//
//==========================================================================

#include "FindFile.h"
#include "wildcard.h"

FindFile::FindFile(FindFileOptions_t &opts)
{
    m_opts = opts;
}
//--------------------------------------------------------------------------

FindFile::~FindFile()
{
    clear();
}
//--------------------------------------------------------------------------

// Combines the two path's together and returns the combined path. This function
// eliminates the problem of combining directories when the left path may or
// may not contain a backslash. eg "c:\ and windows" or "c:\windows and system"
string FindFile::combinePath (string path1, string path2)
{
    if (path1.find_last_of("\\") != path1.length()-1 && path2 != "")
        path1 += "\\";
    path1 += path2;

    return path1;
}
//------------------------------------------------------------------------------

// Re-initializes the FileFind object so that it can be reused without freeing
// and allocating memory every time
void FindFile::clear ()
{
    filelist.clear ();
    listsize = 0;
}
//---------------------------------------------------------------------------

// Searches the location directory for all files and returns
// true if more files may be available and false if that was the last one
bool FindFile::getFiles (HANDLE &searchHandle, WIN32_FIND_DATA &fileData, 
                         string path)
{
    int nValid;

    if (searchHandle == NULL)
    {
        string pathToSearch = combinePath(path, "*");

        searchHandle = FindFirstFile(pathToSearch.c_str(), &fileData);
        nValid = (searchHandle == INVALID_HANDLE_VALUE) ? 0 : 1;
    }
    else
    {
        nValid = FindNextFile(searchHandle, &fileData);
    }

    while (nValid)
    {
        // As long as this file is not . or .., we are done
        if (strcmpi (fileData.cFileName, ".") != 0 &&
            strcmpi (fileData.cFileName, "..") != 0)
            return true;

        nValid = FindNextFile(searchHandle, &fileData);
    }

    FindClose(searchHandle);
    searchHandle = NULL;

    return false;
}
//---------------------------------------------------------------------------

// Returns true if given file information matches requested criteria
bool FindFile::matchCriteria(WIN32_FIND_DATA &filedata)
{
    // Case 1. This is a directory. Check whether it is matched by the exclude
    // directory filter
    if (filedata.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
    {
        if (wildcard::match(filedata.cFileName, m_opts.excludeDir))
            return false;
        return true;
    }

    // Case 2. This is a regular file

    // Check if it meets the filter
    if (!wildcard::match(filedata.cFileName, m_opts.filter))
        return false;

    // Check if it is in the exclude filter
    if (wildcard::match(filedata.cFileName, m_opts.excludeFile))
        return false;

    return true;
}
//---------------------------------------------------------------------------

// Finds all files as specified in the initial options
void FindFile::search ()
{
    clear();
    scanPath (m_opts.location);
}
//---------------------------------------------------------------------------

// Scans a path for files as specified in the filter and stores them in the
// file list array. If a recursive options was specified, scanPath will
// continue to search for files in all subdirectories.
void FindFile::scanPath(string path)
{
    WIN32_FIND_DATA fileData;
    FileInformation fi;

    HANDLE searchHandle = NULL;

    while (getFiles (searchHandle, fileData, path))
    {
        // Abort on termination signal
        if (m_opts.terminateValue && *m_opts.terminateValue)
            break;

        // Skip this file/directory if not matching criteria
        if (!matchCriteria(fileData))
            continue;

        // If recursive option is set and this is a directory, then search in 
        // there too
        if (m_opts.recursive && 
            fileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
            scanPath (combinePath (path, fileData.cFileName));

        // If this is a directory and we don't wish to return directories, 
        // continue
        if (fileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY && 
            !m_opts.returnFolders)
            continue;

        fi.fileinfo = fileData;
        fi.path = path;

        filelist.push_back (fi);
        listsize += fileData.nFileSizeLow + fileData.nFileSizeHigh * MAXDWORD;
    }

}
//---------------------------------------------------------------------------

