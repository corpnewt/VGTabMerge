# VGTabMerge
Small py script to merge `aty_properties` from a VGTab injector kext to the `config.plist -> Devices -> Properties` for WEG injection per [this guide](https://www.tonymacx86.com/threads/guide-injection-of-amd-vega-power-and-fan-control-properties.267519/).

***

## To install:

Do the following one line at a time in Terminal:

    git clone https://github.com/corpnewt/VGTabMerge
    cd VGTabMerge
    chmod +x VGTabMerge.command
    
Then run with either `./VGTabMerge.command` or by double-clicking *VGTabMerge.command*

***

## Usage:

**NOTE:** This script expects that you have already run VGTab-en.app and created your VGTab_xxxx.kext.  If you have not done this yet, see [this guide](https://www.tonymacx86.com/threads/guide-injection-of-amd-vega-power-and-fan-control-properties.267519/) first.  For this example, my VGTab kext and config.plist are located on my desktop, and paths will reflect that.

***

Once you have the script downloaded and open, you'll be presented with the following window:
```
  #######################################################
 #                    VGTab Merge                      #
#######################################################

Current config.plist:  None
        VGTab.kext:    None

C. Select Config.plist
V. Select VGTab.kext

M. Merge

Q. Quit

Please select an option: 
```

Start by selecting `C` (press `c` then enter on your keyboard) to enter the config.plist selection window:
```
  #######################################################
 #              Selecting config.plist                 #
#######################################################

Current config.plist:  None

C. Clear Selection
M. Previous Menu
Q. Quit

Please drag and drop the config.plist:
```

Drag and drop your config.plist onto the terminal window, and you will see its path added automatically.  Press enter to accept it, and you will be taken back to the main menu.  You can see the path for your config.plist listed after `Current config.plist:`.  In my example, the config.plist is on my desktop, so the path for the config in the main menu looked like so:
```
  #######################################################
 #                    VGTab Merge                      #
#######################################################

Current config.plist:  /Users/corp/Desktop/config.plist
        VGTab.kext:    None
```

Select `V` to enter the VGTab.kext selection window, and drag and drop your VGTab_xxxx.kext onto the terminal in the same way you did the config.plist.  Mine is again on the desktop, and after the script took me back to the main menu, looked like so:
```
  #######################################################
 #                    VGTab Merge                      #
#######################################################

Current config.plist:  /Users/corp/Desktop/config.plist
        VGTab.kext:    /Users/corp/Desktop/VegaTab_64.kext/Contents/Info.plist
```
The script will automatically attempt to locate the Info.plist in the dropped kext - if you _only_ have the Info.plist from a VGTab injector kext, that's fine as well, and the script will adjust accordingly.

Once you have the config.plist and VGTab kext located - select `M` to merge the two.

***

## Mid-Merge Prompts:

During the merge, you may be prompted to make some decisions.  By default, the VGTab app adds the `PP_DisablePowerContainment` property with a value of `1` - this is used when overclocking your GPU, but can 0 out your Total Power (in Watts) rendering that sensor data useless.  The script will ask if you'd like to disable it via the following prompt:
```
PP_DisablePowerContainment currently enabled - this disables the
Total Power (in Watts) data point sensor.  If you do not plan to
overclock your GPU - this should be disabled.

Disable? (y/n):
```

If the script locates `PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)/Pci(0x0,0x0)/Pci(0x0,0x0)` as a key in `config.plist -> Device -> Properties`, it will (rightfully) assume that you have some existing properties for your GPU and prompt you to overwrite, merge, or bail on the current merge:
```
There is existing data already for device:
PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)/Pci(0x0,0x0)/Pci(0x0,0x0)

(O)verwrite, (M)erge, (B)ail?:  
```

Those options do the following:
 * `Overwrite` - clears out the existing data for that address and adds the `aty_properties` information from VGTab
 * `Merge` - iterates the keys in the `aty_properties` information, adding (or updating if they exist already) only the information that's different
 * `Bail` - aborts the merge operation without making any changes to the config.plist
