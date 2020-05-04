This is part of a [series of articles](https://github.com/PLCnext/SampleRuntime) that demonstrate how to create a runtime application for PLCnext Control. Each article builds on tasks that were completed in earlier articles, so it is recommended to follow the series in sequence.

## Part 11 - IOConf

PLCnext IOconf Interface generates network configurations for PLCnext controllers via the command line. IOconf was developed for PLCnext users who do not use PLCnext Engineer, but a different development environment, for example exclusively high-level language programming. IOConf supports Axioline Local Bus Devices and Profinet Devices.

This article provides a procedure for the following tasks:

1. Creating custom bus configuration with Axioline I/O modules.

1. Replacing the bus configuration generated in PLCnext Enginner with IOConf Axioline bus configuration.

1. Editing the configuration files on the PLCnext target.


### Technical Background

The PLCnext IOConf Interface is developed in C# and can be executed on Windows and Linux operating system with .Net Core installation.  

### Procedure

1. Download and install the [.NET Core Runtime 3.1.3](https://dotnet.microsoft.com/download/dotnet-core/thank-you/runtime-3.1.3-linux-arm32-binaries) or [SDK 3.1.201](https://dotnet.microsoft.com/download/dotnet-core/thank-you/sdk-3.1.201-linux-arm32-binaries) on the PLCnext target. 
The [procedure for installation .NET Core runtime](https://www.plcnext-community.net/en/hn-makers-blog/424-install-the-net-core-runtime-3-0-0-on-the-axc-f-2152.html#comment-108) is given in the PLCnext Community.
After installation verify the .Net version via command line:
   
   ```
   dotnet --version
   ```

1. Copy the IOConf tool "PLCnIOconf-netstandard2.0" via WinSCP or the command line into the directory "/opt/plcnext" on the PLCnext target. 

1. Open the directory "/opt/plcnext/projects/Default/Io/AxlC" on the PLCnext target and edit the config file "Default.axlc.config":

   ```xml
   <?xml version="1.0" encoding="utf-8" standalone="yes"?>
   <FbIoConfigurationDocument schemaVersion="1.0">
  
      <Includes>
         <!-- Include the SampleRuntime AXIO IO if available -->
         <Include path="$ARP_PROJECTS_DIR$/runtime/Io/Arp.Io.AxlC/*.axlc.config" />  
      </Includes>
  
      <Links path="$ARP_PROJECTS_DIR$/runtime/Io/Arp.Io.AxlC/links.xml" probe="true" />
      
     </FbIoConfigurationDocument>
   ```

1. Open the directory "/opt/plcnext/projects/Default/Plc/FbIo.AxlC" on the PLCnext target and edit the config file "Default.fbio.config":

   ```xml
   <?xml version="1.0" encoding="utf-8" standalone="yes"?>
   <FbIoConfigurationDocument schemaVersion="1.0">
  
      <Includes>
         <Include path="$ARP_PROJECTS_DIR$/runtime/Io/Arp.Io.AxlC/*.fbio.config" />  
      </Includes>

      <Links path="$ARP_PROJECTS_DIR$/runtime/Io/Arp.Io.AxlC/links.xml" probe="true" />

   </FbIoConfigurationDocument>
   ```
   
1. Open the directory "/opt/plcnext/projects/Default/Plc/Gds" on the PLCnext target and edit the config file "Default.gds.config":

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <GdsConfigurationDocument 
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
   xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
   xmlns="http://www.phoenixcontact.com/schema/gdsconfig"
   schemaVersion="1.0" >
  
      <Includes>
         <Include path="$ARP_PROJECTS_DIR$/runtime/Gds/*.gds.config" />
      </Includes>
  
   </GdsConfigurationDocument>
   ```
   This will create two OPC UA data items; one read/write (Input) and one read-only (Output), each holding an integer value. Corresponding GDS variables will also be created using this information.

   This `struct` can include any number of elements. The data type of each element must be taken from the list in Appendix A of the PLCnext Technology User Manual (version 2019.6).

1. Auto-generate the remaining C++ source code, and configuration (`*.meta`) files, for the project. From the root directory of the RuntimeOpc project:

   ```
   plcncli generate code
   plcncli generate config
   ```

1. Build the project. From the root directory of the project:

   ```
   plcncli build
   ```

1. In the project root directory, create a new directory called `data`.

1. In the `data` directory, create a new file named `RuntimeOpc.plm.config`, containing the following text:

   ```xml
    <?xml version="1.0" encoding="utf-8"?>
    <PlmConfigurationDocument xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" schemaVersion="1.3" xmlns="http://www.phoenixcontact.com/schema/plmconfig">
    <Libraries>
        <Library name="RuntimeOpc" binaryPath="/opt/plcnext/projects/RuntimeOpc/libRuntimeOpc.so" />
    </Libraries>
    <Components>
        <Component name="Runtime" type="RuntimeOpc.RuntimeOpcComponent" library="RuntimeOpc">
        <Settings path="" />
        </Component>
    </Components>
    </PlmConfigurationDocument>
   ```

   This instructs the PLCnext runtime to create one instance of the RuntimeOpcComponent component, called Runtime, from the RuntimeOpc shared object library that we have just built.

1. Download the application to the PLC. From the project root directory copy the following files:

   - Shared object library containing the PLM component.

   ```
   ssh admin@192.168.1.10 'mkdir -p projects/RuntimeOpc'
   scp bin/AXCF2152_20.0.0.24752/Release/lib/libRuntimeOpc.so admin@192.168.1.10:~/projects/RuntimeOpc
   ```

   - PLM metadata files.

   ```
   scp -r intermediate/config/* admin@192.168.1.10:~/projects/RuntimeOpc
   ```

   - PLM configuration file.

   ```
   scp data/RuntimeOpc.plm.config admin@192.168.1.10:~/projects/Default/Plc/Plm
   ```

1. On the PLC, edit the file `/opt/plcnext/projects/Default/Plc/Plm/Plm.config`. In the `<Includes>` section, do not delete or change any existing lines, but add the following new lines:
   ```xml
   <!-- Include all other plm.config files in this folder -->
   <Include path="*.plm.config" />
   ```

1. On the PLC, edit the file `/opt/plcnext/projects/PCWE/Services/OpcUA/PCWE.opcua.config`. In the `<GdsPortsToProvide>` section, change the value `<None />` to `<All />`. That section of the file should then look like:

   ```xml
   <GdsPortsToProvide>
     <All />
   </GdsPortsToProvide>
   ```

1. Restart the PLCnext runtime:

   ```
   sudo /etc/init.d/plcnext restart
   ```

1. In an OPC UA client like UaExpert from Unified Automation:
   - In the Address Space pane, open the branch PLCnext -> Runtime
   - Add the two new data items to the Data Access View pane.
   - Attempt to change the value of both data items. It is not possible to change the value of the Output (read-only) data item.

These OPC UA variables can now be used by the runtime application.

### Next steps

GDS variables corresponding to the new OPC UA data items have been created and are available to any application that can access the Global Data Space. The runtime application can exchange data with these GDS variables using the "Data Access" and/or "Subscription" RSC services.

---

Copyright © 2020 Phoenix Contact Electronics GmbH

All rights reserved. This program and the accompanying materials are made available under the terms of the [MIT License](http://opensource.org/licenses/MIT) which accompanies this distribution.
