import os
import requests
import yaml
from datetime import datetime

# Folder to monitor
folder = "/tmp/geotools/hdfs"
# Maximum size in bytes (50 GB)
max_size = 50 * 1024 * 1024 * 1024


def load_yml(yml_path):
    """
    Load yml file as a dict
    :param yml_path: file path
    :return: yml file content as a dict
    """
    yml_file = open(yml_path)
    yml_dict = yaml.load(yml_file, Loader=yaml.FullLoader)
    return yml_dict


def get_folder_size(folder):
    """Calculate the total size of the folder, including all files and subdirectories."""
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(folder):
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            if os.path.isfile(filepath):
                total_size += os.path.getsize(filepath)
    return total_size


def sort_files_by_mod_time(folder):
    """Sort files in the folder by last access time."""
    # List all files in the folder (without subdirectories)
    files = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]

    # Sort the files by last access time
    sorted_files = sorted(
        files, key=lambda f: os.path.getatime(os.path.join(folder, f))
    )

    return sorted_files


credentials_dict = load_yml(
    f"{os.path.dirname(os.path.abspath(__file__))}/credentials.yml"
)

if os.path.exists(folder):
    folder_size = get_folder_size(folder)
    ordered_files = sort_files_by_mod_time(folder)

    while folder_size > max_size:
        file = ordered_files.pop(0)
        folder_size = folder_size - os.path.getsize(folder + "/" + file)
        layername = os.path.splitext(os.path.split(file)[1])[0]
        os.remove(folder + "/" + file)
        response = requests.get(
            f"{credentials_dict['geoserver']['url']}/rest/layers/{layername}",
            auth=(
                credentials_dict["geoserver"]["user"],
                credentials_dict["geoserver"]["password"],
            ),
        )
        response.raise_for_status()
        workspace = response.json()["layer"]["resource"]["name"].split(":")[0]
        response = requests.post(
            f"{credentials_dict['geoserver']['url']}/rest/workspaces/{workspace}/coveragestores/{layername}/reset",
            auth=(
                credentials_dict["geoserver"]["user"],
                credentials_dict["geoserver"]["password"],
            ),
        )
        response.raise_for_status()

    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Cleanup complete. Folder size: {folder_size / (1024 * 1024):.2f} MB")

