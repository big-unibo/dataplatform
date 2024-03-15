import argparse

def main():
    parser = argparse.ArgumentParser(description='Example script with argument parsing')
    parser.add_argument('--name-argument', help='Argument passed from Airflow DAG', required=True)
    args = parser.parse_args()

    # Use the argument in your Python code
    print("Hello,", args)

if __name__ == "__main__":
    main()