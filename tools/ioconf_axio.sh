#! /bin/sh

# delete an existing project
if [ -f "Projects/SampleRuntime.ioconf" ]; then
    # delete does not work 
    # dotnet IOConf.dll delete -n "Projects/SampleRuntime.ioconf"

    # use rm instead
    rm -rf Projects/SampleRuntime{,.ioconf}
fi

# create new project
dotnet IOConf.dll new empty -n "Projects/SampleRuntime.ioconf"

# add a new AXC F 2152 controller to the project for later usage
dotnet IOConf.dll add -n "Projects/SampleRuntime.ioconf" -d "Fdcml/AXC F2152v00_2019.6.0.fdcml"
# insert the controller instance to the project, composition can reference fdcml files
dotnet IOConf.dll compose insert -n "Projects/SampleRuntime.ioconf" -p PROJECT -d "Fdcml/AXC F2152v00_2019.6.0.fdcml"

# add a new IO device to the project
dotnet IOConf.dll add -n "Projects/SampleRuntime.ioconf" -d "Fdcml/AXL F DI8_1 DO8_1 1H.fdcml"
# insert device instance into project by querying known devices, that have been added to project before
dotnet IOConf.dll compose insert -n "Projects/SampleRuntime.ioconf" -p PROJECT/1 -d "{ProductName=AXL F DI8/1 DO8/1 1H}"

# add another new IO device type to project
dotnet IOConf.dll add -n "Projects/SampleRuntime.ioconf" -d "Fdcml/AXL F AI2 AO2 1Hv02_1.00.fdcml"
# insert device instance into project
dotnet IOConf.dll compose insert -n "Projects/SampleRuntime.ioconf" -p PROJECT/1 -d "{ProductName=AXL F AI2 AO2 1H,Version=02/1.00}"

# list the content of the project
dotnet IOConf.dll list -n "Projects/SampleRuntime.ioconf"

# compile project with output to folder Projects/tic
dotnet IOConf.dll compile -n "Projects/SampleRuntime.ioconf" -o Projects/SampleRuntime/Io
