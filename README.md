# SimpleAnnotate
A simple annotation software package

What is SimpleAnnotate?

SimpleAnnotate is a bare-bones, open source video and image annotation software for, currently only for OSX.  SimpleAnnotate can be used for both image labeling and object tracking.

Why use SA?

We all know how tedious annotating data can be. SimpleAnnotate is a great choice for those who want a simple, no-frills annotation software to quickly plow through dataset annotation. The learning curve is low, and results are efficient.
 
Who uses SA?
SimpleAnnotate is being used by multiple labs around the country, including VIPER Lab at Purdue, SmileLab at Northeastern University, and The Computer Vision Lab at RPI and Oak Ridge National Laboratory Electronic Systems Research Division (EESRD)
 
Here are the release notes:
 
Version 2 of Simple Annotate is finally here! A lot of bugs have been fixed, and a even more features have been added. This program is designed for OSX 10.8 and above.
 
Installation notes:
To install the binary, please ensure that the latest version of boost is installed on your machine in a default directory.
 
Function List:
Load/Save:
-Command+O: Open new folder filled with images
-Command+Shift+O: Open previous project
-Command+S: Save project progress to current working directory
-Command+Shift+S: Save project progress to custom directory
-Command+Shift+E: Export progress to Anchovy format
--NOTE: SimpleAnnotate auto-saves your project as you go, in case the application unexpectedly quits.  To recover your auto-saved work, use: File->Recover Previous Project

 
Video Navigation:
Right arrow: Move Forward X amount of frames*
Left arrow: Move Backward X amount of frames*
*Amount of frames X to jump by default can be changed in "Frames to Skip" field on left
"Jump to Frame" Field allows you to jump to specific places by hitting the "jump" button
"Play" currently does not work correctly
 
Annotation:
--Rectangles and Ellipses (Square tool icon and circle tool icon):
Command+click: Create new rectangle of size M x N*
*Set this size in "Default Rectangle Size" field
Command+drag: Create new rectangle of custom size
Rectangle Corner Drag: Change Rectangle Size
Shift+click: Delete rectangle
Command+Delete: Delete all rectangles in current frame
Command+C: Copy rectangles from previously annotated frame into current frame
 
--Sets of Points ("x" tool icon):
Command+Option+Click: Start new set of points
Command+Click: Add point to existing set of points

--Smart Lasso (Magnet icon under "x" tool icon)
Command+Option+Click: Start new magnetic lasso session
Command+Click: Append magnetic lasso to clicked point
Command+Drag: Drag to append magnetic lasso
Enter: Finish current magnetic lasso session

--Face Detection can be performed using the "Detect Faces" button

Tracking (BUGGY):
Function+clicking a rectangle: 1) Highlights rectangle as purple.  This rectangle will now auto-track on a Command+C copy. 2) Function click again to de-select a rectangle and turn off tracking 
 
 
 
The bottom left corner of the screen holds a list of current rectangles in the frame.  You can rename any given rectangle to a custom name.  These names will be saved in the log file upon saving the project.
 
By hitting command+S, you save your project.  All cropped images, along with a annotation log, will be placed in the folder "pedestrianCrops" located in the current working directory.
