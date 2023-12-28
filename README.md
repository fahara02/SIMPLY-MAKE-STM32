
# SIMPLY-MAKE-STM32



A STM32 template file with CMSIS ,STM32 standard perpheral library and multi subdirectory type structure. 
MAKE file will automatically find all includes no need to manually add any includes.debug file will be automatically created and destroyed.

run with windows wsl after installing GNU arm-none-eabi-gcc on wsl 



## License

[MIT](https://choosealicense.com/licenses/mit/)



## Prerequisite

1. CROSS COMPILER "arm-none-eabi-gcc " installation on wsl windows
```bash
$ sudo apt-get remove binutils-arm-none-eabi gcc-arm-none-eabi
$ sudo add-apt-repository ppa:team-gcc-arm-embedded/ppa
$ sudo apt-get update
$ sudo apt-get install gcc-arm-none-eabi
$ sudo apt-get install gdb-arm-none-eabi
```



## Installation

1. Clone the template :

```bash
git clone https://github.com/fahara02/SIMPLY-MAKE-STM32.git
```
2. Go to the template directory:

```bash
cd SIMPLY-MAKE-STM32
```
3. Open it on visual studio code

```bash
code .
```
4. run make on wsl terminal

```bash
make
```




