//==========================================================================
// FindFile.h
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

#include <stdio.h>
#include <string>
#include <vector>

using namespace std;


// Specifies settings to use for searching for files
struct FindFileOptions_t
{
    bool recursive;         // Whether to look inside subdirectories
    bool returnFolders;     // Return folder names as results too

    bool *terminateValue;   // Value to check to see whether search should be
                            // terminated

    string location;        // Where to search for files

    string filter;          // Filter for files to be included

    string excludeFile;     // Exclude filter for files
    string excludeDir;      // Exclude filter for directories
};

// Holds information on a found file
struct FileInformation
{
    WIN32_FIND_DATA fileinfo;
    string path;
};

// A list of found files
typedef vector<FileInformation> FileList_t;


class FindFile
{
private:

    FindFileOptions_t m_opts;

    // Scans a path for files as according to 
    void scanPath(string path);

    // Finds a single file and returns true if there are more to come
    bool getFiles;

    // Returns true if given file information matches requested criteria
    bool matchCriteria;

public:

    FileList_t filelist;        // List of files found in search
    int listsize;           // Size in bytes of all files in found list

    FindFile(FindFileOptions_t &opts);
    ~FindFile ();

    // Clears list of found files, file handle and so on
    void clear();

    // Finds all files as specified in the initial options
    void search ();

    // Concatenates 2 paths
    static string combinePath(string path1, string path2);
};

