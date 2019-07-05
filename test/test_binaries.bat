@echo off
start /b cmd /c yarp server
timeout 3 > NUL
start /b cmd /c yarp read /portread
timeout 10 > NUL
start /b cmd /c yarp write /portwrite
timeout 10 > NUL
start /b cmd /c yarp connect /portwrite /portread
