# Yosys + GHDL Mixed Language Template

## Introduction

This template enables you to synthesize mixed-language HDL projects (VHDL + Verilog) targeting ICE40 FPGAs.

### Goals
- **Open Source Toolchain**: Uses only free, open-source FPGA tools
- **Mixed Language Support**: Combine VHDL and Verilog in a single project
- **Automated Synthesis**: GitHub Actions to quickly build after commits

### Backend Technologies
- **[Yosys](https://yosyshq.net/yosys/)**: Open-source synthesis suite for Verilog
- **[GHDL](https://github.com/ghdl/ghdl)**: Open-source VHDL simulator and synthesizer
- **[GHDL-Yosys Plugin](https://github.com/ghdl/ghdl-yosys-plugin)**: Translates VHDL into YosysIR
- **[nextpnr](https://github.com/YosysHQ/nextpnr)**: Portable FPGA place-and-route tool for ICE40 and other FPGAs
- **[IceStorm](https://github.com/YosysHQ/icestorm)**: Bitstream generation tools for Lattice ICE40 FPGAs

### Build Automation
The project includes automated GitHub Actions workflows that:
- Trigger on HDL file changes (`.vhd`, `.vhdl`, `.v`)
- Uses the `hdlc/ghdl:yosys` container
- Generate synthesis artifacts (JSON, ASC, BIN files)
- Upload build artifacts for download

## Example Project Structure

```
├── .github/workflows/
│   └── synth.yml           # GitHub Actions workflow
├── scripts/
│   └── ice40up5k_synth.ys  # Yosys synthesis script
├── vhdl/
│   └── top.vhd            # VHDL top-level entity
├── verilog/
│   ├── and2.v             # Verilog AND gate module
│   └── or2.v              # Verilog OR gate module
├── io.pcf                 # Pin constraint file for ICE40UP5K
└── README.md              # This file
```

### Current Design
The example design implements a simple logic function `d_o = (a_i & b_i) | c_i`:
- **VHDL Top Entity** (`vhdl/top.vhd`): Main design entity that instantiates Verilog components
- **Verilog Components**: Basic logic gates (`and2.v`, `or2.v`) implemented in Verilog
- **Mixed Integration**: VHDL entity instantiates Verilog modules using component declarations

## Adding Files to the Build

### Adding VHDL Files
1. Place your VHDL files in the `vhdl/` directory
2. Update the synthesis script `scripts/ice40up5k_synth.ys`:
   ```tcl
   ghdl --std=08 -fsynopsys -frelaxed-rules \
       vhdl/top.vhd \
       vhdl/your_new_file.vhd \  # Add your file here
       -e top;
   ```

### Adding Verilog Files
1. Place your Verilog files in the `verilog/` directory
2. Update the synthesis script `scripts/ice40up5k_synth.ys`:
   ```tcl
   read_verilog \
       verilog/and2.v \
       verilog/or2.v \
       verilog/your_new_module.v  # Add your file here
   ```

### Updating Pin Constraints
Modify `io.pcf` to match your design's I/O:
```
set_io signal_name pin_number
```

## Environment Setup
The key dependancies (yosys, ghdl and ghdl-yosys-plugin) were originally built from source on an Ubuntu 24.04 Server VM. The steps are as follows. 

Download Build Dependancies:
```bash
cd ..
sudo apt-get install build-essential clang bison flex libreadline-dev gawk tcl-dev libffi-dev git graphviz xdot pkg-config python3 libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev
```

Build Yosys:
```bash
git clone https://github.com/YosysHQ/yosys
cd yosys
make config-gcc
make
sudo make install
```

Build GHDL:
```bash
cd ..
sudo apt install gnat-10
git clone https://github.com/ghdl/ghdl
cd ghdl
./configure --prefix=/usr/local
make
sudo make install
```

Build ghdl-yosys-plugin:
```bash
cd ..
git clone https://github.com/ghdl/ghdl-yosys-plugin
cd ghdl-yosys-plugin
make
sudo cp ghdl.so /usr/local/share/yosys/plugins/ghdl.so
```

### Docker Alternative
Use the same container as the CI workflow:
```bash
docker run --rm -v $(pwd):/work -w /work hdlc/ghdl:yosys \
    bash -c "apt update && apt install nextpnr-ice40 fpga-icestorm -y && yosys -s scripts/ice40up5k_synth.ys"
```

## Manual IP Build Instructions

### 1. Verify Tool Installation
```bash
yosys -V
ghdl --version
nextpnr-ice40 --version
icepack --help
```

### 2. Run Synthesis
```bash
# Execute the complete synthesis flow
yosys -s scripts/ice40up5k_synth.ys
```

This command will:
1. Load the GHDL plugin for VHDL support
2. Read all Verilog source files
3. Analyze and elaborate VHDL files with GHDL
4. Synthesize to ICE40 primitives
5. Perform place-and-route with nextpnr
6. Generate the final bitstream

### 3. Generated Outputs
- `top.json`: Post-synthesis netlist
- `top.asc`: Post-place-and-route ASCII file
- `ice40up5k_top.bin`: Final bitstream ready for programming

### 4. Programming the FPGA
```bash
# Using iceprog (if you have compatible hardware)
iceprog ice40up5k_top.bin

# Or convert to other formats as needed
icepack top.asc top.bin
```

## Extending to Other FPGAs

To target different FPGA families:
1. Replace `synth_ice40` with appropriate synthesis command (`synth_xilinx`, `synth_intel`, etc.)
2. Update place-and-route tool (`nextpnr-xilinx`, `vivado`, etc.)
3. Modify pin constraints file format
4. Update bitstream generation commands

## Troubleshooting

### Common Issues
- **GHDL Plugin Not Found**: Ensure `ghdl-yosys-plugin` is installed
- **Synthesis Errors**: Check VHDL/Verilog syntax and component/module names match
- **Place-and-Route Fails**: Verify pin constraints and design doesn't exceed FPGA resources

### Getting Help
- [Yosys Documentation](https://yosyshq.readthedocs.io/)
- [GHDL Documentation](https://ghdl.readthedocs.io/)
- [ICE40 Tools](https://github.com/YosysHQ/icestorm)
