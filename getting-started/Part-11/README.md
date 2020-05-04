This is part of a [series of articles](https://github.com/PLCnext/SampleRuntime) that demonstrate how to create a runtime application for PLCnext Control. Each article builds on tasks that were completed in earlier articles, so it is recommended to follow the series in sequence.

## Part 11 - IOConf

PLCnext IOconf Interface generates network configurations for PLCnext controllers via the command line. IOconf was developed for PLCnext users who do not use PLCnext Engineer, but a different development environment, for example exclusively high-level language programming. IOConf supports Axioline Local Bus Devices and Profinet Devices.

This article provides a procedure for the following tasks:

1. Installation of `.Net Core Runtime 3.1.3` on PLCnext target.

1. Installation of `PLCnIOconf-netstandard2.0` on PLCnext target.

1. Creating custom bus configuration with Axioline I/O modules.

1. Replacing the bus configuration generated in PLCnext Enginner with IOConf Axioline bus configuration.

1. Editing the configuration files on the PLCnext target.


### Technical Background

The PLCnext IOConf Interface is developed in C# and can be executed on Windows and Linux operating systems with .Net Core installation.  

### Procedure

1. Download and install the [.NET Core Runtime 3.1.3](https://dotnet.microsoft.com/download/dotnet-core/thank-you/runtime-3.1.3-linux-arm32-binaries) or [SDK 3.1.201](https://dotnet.microsoft.com/download/dotnet-core/thank-you/sdk-3.1.201-linux-arm32-binaries) on the PLCnext target. 
The [procedure for installation .NET Core runtime](https://www.plcnext-community.net/en/hn-makers-blog/424-install-the-net-core-runtime-3-0-0-on-the-axc-f-2152.html#comment-108) is given in the PLCnext Community.
After installation verify the .Net version via command line:
   
   ```bash
   dotnet --version
   ```

1. Copy the IOConf tool `PLCnIOconf-netstandard2.0` via WinSCP or the command line into the directory `/opt/plcnext` on the PLCnext target. 

1. Copy the `ioconf_axio.sh` script located in the [tools](https://github.com/PLCnext/SampleRuntime/tree/master/tools) folder into `/opt/plcnext/PLCnIOconf-netstandard2.0/bin` directory on the plcnext target.

1. Make the script `ioconf_axio.sh` executable and execute it.

   ```bash
   chmod +x ioconf_axio.sh
   
   ./ioconf_axio.sh
   ```
   
1. After successful execution, find the Axioline I/O bus configuration in `/opt/plcnext/PLCnIOconf-netstandard2.0/bin/Projects/SampleRuntime/Io/ID_Token/PLCnext` directory (folders `Arp.Io.AxlC` and `Arp.Io.PnC`).

1. In the `/opt/plcnext/projects/runtime` directory create a new directory called `Io`.

1. Copy the `Arp.Io.AxlC` and `Arp.Io.PnC` folders located in `/opt/plcnext/PLCnIOconf-netstandard2.0/bin/Projects/SampleRuntime/Io/ID_Token/PLCnext` to `/opt/plcnext/projects/runtime/Io` directory.

1. Open the Default-Io directory `/opt/plcnext/projects/Default/Io/AxlC` on the PLCnext target and edit the config file `Default.axlc.config`:

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

1. Open the Default-Plc directory `/opt/plcnext/projects/Default/Plc/FbIo.AxlC` on the PLCnext target and edit the config file `Default.fbio.config`:

   ```xml
   <?xml version="1.0" encoding="utf-8" standalone="yes"?>
   <FbIoConfigurationDocument schemaVersion="1.0">
  
      <Includes>
         <Include path="$ARP_PROJECTS_DIR$/runtime/Io/Arp.Io.AxlC/*.fbio.config" />  
      </Includes>

      <Links path="$ARP_PROJECTS_DIR$/runtime/Io/Arp.Io.AxlC/links.xml" probe="true" />

   </FbIoConfigurationDocument>
   ```
   
1. Restart the PLCnext runtime:

   ```
   sudo /etc/init.d/plcnext restart
   ```

### Next steps

---

Copyright © 2020 Phoenix Contact Electronics GmbH

All rights reserved. This program and the accompanying materials are made available under the terms of the [MIT License](http://opensource.org/licenses/MIT) which accompanies this distribution.
