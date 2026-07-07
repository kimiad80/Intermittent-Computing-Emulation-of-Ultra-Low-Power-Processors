import argparse


def bin_to_mem(input_file, output_file, text_start=0x00000000, little_endian=True):
    try:
        # Read the entire binary file into memory
        with open(input_file, "rb") as bin_file:
            binary_data = bin_file.read()

        if not binary_data:
            raise ValueError("Input file is empty")

        with open(output_file, "w") as mem_file:
            byte_offset = 0
            while byte_offset < len(binary_data):
                # Read 4 bytes at a time (32-bit word)
                chunk = binary_data[byte_offset:byte_offset + 4]

                # Pad incomplete last word with zeros
                if len(chunk) < 4:
                    chunk += b'\x00' * (4 - len(chunk))

                # Convert little-endian bytes to big-endian hex word
                if little_endian:
                    chunk = chunk[::-1]

                hex_word = ''.join(f"{byte:02X}" for byte in chunk)
                mem_file.write(f"{hex_word}\n")

                byte_offset += 4

        print(f"Successfully generated '{output_file}'.")

    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
    except ValueError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"Error processing file: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Convert a RISC-V binary file to a Verilog .mem file."
    )

    parser.add_argument(
        "input_file",
        help="Input binary file (e.g., program.bin)"
    )

    parser.add_argument(
        "output_file",
        help="Output memory file (e.g., program.mem)"
    )

    parser.add_argument(
        "--text-start",
        type=lambda x: int(x, 0),
        default=0x00000000,
        help="Text section start address (default: 0x00000000)"
    )

    parser.add_argument(
        "--big-endian",
        action="store_true",
        help="Treat input as big-endian (default is little-endian)"
    )

    args = parser.parse_args()

    bin_to_mem(
        args.input_file,
        args.output_file,
        text_start=args.text_start,
        little_endian=not args.big_endian,
    )