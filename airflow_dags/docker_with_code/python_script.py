import argparse

# Define command-line arguments
parser = argparse.ArgumentParser(description='Description of your script')
parser.add_argument('--option1', help='Description of option 1')
parser.add_argument('--option2', help='Description of option 2')

# Parse command-line arguments
args = parser.parse_args()

# Access command-line options
option1_value = args.option1
option2_value = args.option2

# Use the command-line options in your script
print("Option 1:", option1_value)
print("Option 2:", option2_value)