#!/usr/bin/env python

import os, sys

from Scripts import *



class VGTM:

    def __init__(self):

        self.u = utils.Utils("VGTab Merge")

        self.config  = None

        self.kext    = None

        self.devpath = "PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)/Pci(0x0,0x0)/Pci(0x0,0x0)"



    def select_file(self, name = "config.plist"):

        self.u.head("Selecting {}".format(name))

        print("")

        print("Current {}:  {}".format(name, self.config if name == "config.plist" else self.kext))

        print("")

        print("C. Clear Selection")

        print("M. Previous Menu")

        print("Q. Quit")

        print("")

        menu = self.u.grab("Please drag and drop the {}:  ".format(name))

        if not len(menu):

            return self.select_file(name)

        if menu.lower() == "q":

            self.u.custom_quit()

        elif menu.lower() == "m":

            return self.config if name == "config.plist" else self.kext

        elif menu.lower() == "c":

            if name == "config.plist":

                self.config = None

            else:

                self.kext = None

            return self.select_file(name)

        # Check if file exists

        fpath = self.u.check_path(menu)

        if not fpath:

            self.u.head("Error")

            print("")

            print("That file does not exist.")

            print("")

            self.u.grab("Press [enter] to return...")

            return self.select_file(name)

        # If this is the config.plist, or we don't have the nested Info.plist, just return the path

        if name == "config.plist" or not os.path.exists(os.path.join(fpath,"Contents","Info.plist")):

            return fpath

        # Nested path exists - return it instead

        return os.path.join(fpath,"Contents","Info.plist")



    def ensure(self, path_list, dict_data):

        item = dict_data

        for path in path_list:

            if not path in item:

                item[path] = {}

            item = item[path]

        return dict_data



    def merge(self):

        # Get values if they don't already exist

        self.config = self.select_file("config.plist") if self.config == None else self.config

        if self.config == None:

            return

        self.kext = self.select_file("VGTab.kext") if self.kext == None else self.kext

        if self.kext == None:

            return

        # Should have valid values here

        self.u.head("Merging Plist Data")

        print("")

        print("Loading {}...".format(os.path.basename(self.config)))

        try:

            with open(self.config,"rb") as f:

                config_data = plist.load(f)

        except:

            print(" - Failed to load!")

            print("")

            self.u.grab("Press [enter] to return...")

            return

        print("Loading {}...".format(os.path.basename(self.kext)))

        try:

            with open(self.kext,"rb") as f:

                kext_data = plist.load(f)

        except:

            print(" - Failed to load!")

            print("")

            self.u.grab("Press [enter] to return...")

            return

        # Check for IOKitPersonalities -> Controller -> aty_properties in kext_data

        print("Verifying {}...".format(os.path.basename(self.kext)))

        aty = kext_data.get("IOKitPersonalities",{}).get("Controller",{}).get("aty_properties",None)

        if not aty:

            print(" - aty_properties not found!")

            print("")

            self.u.grab("Press [enter] to return...")

            return

        print(" - Found aty_properties!")

        if aty.get("PP_DisablePowerContainment",0) == 1:

            print("")

            print("PP_DisablePowerContainment currently enabled - this disables the")

            print("Total Power (in Watts) data point sensor.  If you do not plan to")

            print("overclock your GPU - this should be disabled.")

            print("")

            while True:

                check = self.u.grab("Disable? (y/n):  ")

                if check.lower() == "n":

                    print("\n - PP_DisablePowerContainment remains enabled.\n")

                    break

                elif check.lower() == "y":

                    aty["PP_DisablePowerContainment"] = 0

                    print("\n - PP_DisablePowerContainment disabled.\n")

                    break

        print("Merging into {}...".format(os.path.basename(self.config)))

        # Ensure the config -> Devices -> Properties -> devpath exists

        config_data = self.ensure(["Devices","Properties",self.devpath],config_data)

        if not len(config_data["Devices"]["Properties"][self.devpath]):

            config_data["Devices"]["Properties"][self.devpath] = aty

        else:

            print("")

            print("There is existing data already for device:\n{}".format(self.devpath))

            print("")

            while True:

                check = self.u.grab("(O)verwrite, (M)erge, (B)ail?:  ")

                if check.lower() in ["o","overwrite"]:

                    print("\n - Overwritten.\n")

                    config_data["Devices"]["Properties"][self.devpath] = aty

                    break

                elif check.lower() in ["m","merge"]:

                    for x in aty:

                        config_data["Devices"]["Properties"][self.devpath][x] = aty[x]

                    print("\n - Merged.\n")

                    break

                elif check.lower() in ["b","bail"]:

                    print("\n - Bailing...\n")

                    self.u.grab("Press [enter] to return...")

                    return

        # Write the finalized config

        print("Writing data to {}...".format(os.path.basename(self.config)))

        try:

            with open(self.config,"wb") as f:

                plist.dump(config_data,f)

        except:

            print(" - Failed to write!")

            print("")

            self.u.grab("Press [enter] to return...")

            return

        print("")

        print("Done.")

        print("")

        self.u.grab("Press [enter] to return...")



    def main(self):

        self.u.head()

        print("")

        print("Current config.plist:  {}".format(self.config))

        print("        VGTab.kext:    {}".format(self.kext))

        print("")

        print("C. Select Config.plist")

        print("V. Select VGTab.kext")

        print("")

        print("M. Merge")

        print("")

        print("Q. Quit")

        print("")

        menu = self.u.grab("Please select an option:  ").lower()

        if not len(menu):

            return

        if menu == "q":

            self.u.custom_quit()

        elif menu == "c":

            self.config = self.select_file("config.plist")

        elif menu == "v":

            self.kext = self.select_file("VGTab.kext")

        elif menu == "m":

            self.merge()

        return



if __name__ == '__main__':

    v = VGTM()

    while True:

        try:

            v.main()

        except Exception as e:

            print(e)

            if sys.version_info >= (3, 0):

                input("Press [enter] to return...")

            else:

                raw_input("Press [enter] to return...")