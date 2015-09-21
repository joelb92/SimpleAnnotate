//=============================================================================
// Author: Louka Dlagnekov
// File: wildcard.cpp
// Description: This code compares a file name with a filter to determine
//              whether the filter properly matches the file name.
//              Some of this code is downloaded from
//              http://www.1cplusplusstreet.com/ It has been extended to include
//              multiple filters separated by a ';'
//
// Original copyright notice:
//**************************************
//     
// Name: ^NEW^ -- wildcard string compar
//     e (globbing)
// Description:matches a string against 
//     a wildcard string such as "*.*" or "bl?h
//     .*" etc. This is good for file globbing 
//     or to match hostmasks.
// By: Jack Handy
//
// Returns:1 on match, 0 on no match.
//
//This code is copyrighted and has// limited warranties.Please see http://
//     www.1CPlusPlusStreet.com/xq/ASP/txtCodeI
//     d.1680/lngWId.3/qx/vb/scripts/ShowCode.h
//     tm//for details.//**************************************
// 
//=============================================================================
 
#include "wildcard.h"

// Allows multiple filters separated by ';'
bool wildcard::match (string file, string _filter)
{
    string subfilter;
    string filter = _filter;

    if (_filter == "")
        return false;

    while (filter.find(";") != -1)
    {
        subfilter = filter.substr(0, filter.find(";"));
        filter.erase(0, filter.find(";")+1);
        if (wildcmp (subfilter, file))
            return true;
    }
    return wildcmp (filter, file);
}
//----------------------------------------------------------------------------

/* the main wildcard compare function */
bool wildcard::wildcmp(string _findstr, string _cmp)
{
  bool retval = true;
  char findstr[1024], cmp[1024];

  strcpy (findstr, _findstr.c_str());
  strcpy (cmp, _cmp.c_str());
  
  int len = (int) strlen(findstr);

  //we alter the search string, so lets make a copy here
  //and alter it instead
  char *srch = new char[len+1];
  strcpy(srch,findstr);

  if (*srch != '*' && !StartCmp(srch,cmp))
    retval = false;
  else if (srch[len-1] != '*' && !EndCmp(srch,cmp))
    retval = false;
  else {
    //srch may have been changed in StartCmp and/or EndCmp
    //so we need to reset 'len' to the new length
    len = (int) strlen(srch);

    //get space for the new search string
    char *s = new char[len+1];
    int j=0;

    for (int i=0;i<len && retval;++i)
      if (srch[i] != '*') {
        //build the new search string
        s[j++] = srch[i];
        s[j] = '\0';

        //make sure it's found in the source string
        if (!find(s,cmp))
          retval = false;

        //if we reach a * in the middle of the search
        //string, reset string s to start building
        //the next part of the search string after the *
        if (srch[i+1] == '*') {
          *s = '\0';
          j=0;
        }
      }
    delete [] s;
  }
  delete [] srch;
  return retval;
}
//----------------------------------------------------------------------------

/* Helper Functions */

//check string for substring
bool wildcard::find(const char *s1,const char *s2)
{
  int srchlen=(int)strlen(s1);
  int cmplen=(int)strlen(s2);

  for (int i=0;i<cmplen;++i)
    if(wc_cmp(s1,s2+i,srchlen))
      return true;

  return false;
}
//----------------------------------------------------------------------------

//replacement for strncmp, allows for '?'
bool wildcard::wc_cmp(const char *s1,const char *s2,int len)
{
  for (int i=0;i<len;++i)
    if (s1[i] != s2[i] && s1[i] != '?')
      return false;
  return true;
}
//----------------------------------------------------------------------------

//if there's no * at end of the search string, it
//is checked to be identical to the end of the source string
bool wildcard::EndCmp(char *src,const char *cmp)
{
  int slen=(int) strlen(src);
  int clen=(int) strlen(cmp);

  int j=slen-1;
  for (int i=clen-1;i>0 && src[j] != '*';--i,--j)
    if(src[j] != cmp[i] && src[j] != '?')
      return false;
  src[j] = '\0';

  return true;
}
//----------------------------------------------------------------------------

//if there's no * at head of search string, it
//is checked to be identical to the start of the source string
bool wildcard::StartCmp(char *src,const char *cmp)
{
  int len = (int)strlen(cmp);

  int i=0;
  for ( ;i<len && src[i] != '*';++i)
    if (src[i] != cmp[i] && src[i] != '?')
      return false;

  if (i < len)
    strncpy(src,src+i,strlen(src)-i+1);

  return true;
}
//----------------------------------------------------------------------------

