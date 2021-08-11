# subsurface

![we all live in a nuclear submarine...](https://e7.pngegg.com/pngimages/781/160/png-clipart-type-214-submarine-uss-nautilus-ssn-571-u-boat-dolphin-class-submarine-submarine-miscellaneous-vehicle.png)

A domain recon tool capable of finding subdomains and subnets and then harvesting HTTP screen shots and whois data about them.

## Usage

Subsurfce has two modes, in the default mode it just enumerates subdomains.
To use this just type:
```{bash}
$ ./subsurface.sh fbi.gov
```
This will output results into a new `./fbi.gov` in the current directory.

In the other mode subsurface also enumerates all the subnets that the identified subdomains are a part of and scans these for active hosts which then are also used to harvest screen grabs of any running http servers.
To do this just add the `-subnet` flag:
```{bash}
$ ./subsurface.sh cia.gov -subnet
```

## Installation

Before you can run subsurface you will need to make sure that you have the following programs installed and available via your `PATH` environmental variable.
    - subfinder
    - amass
    - assetfinder
    - sublist3r
    - gowitness
    - fping
    - whois

## Problems and Contributions

If you have noticed any bugs or wish to contribute to the project by all means go ahead and open and issue or pull request respectively and I'll be sure to take a look!
Any help with this is project is quite welcome.
