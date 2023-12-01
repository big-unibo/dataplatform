from hdfs import InsecureClient

def create_hdfs_directory(client, directory_path):
    try:
        # Crea la directory utilizzando InsecureClient
        client.makedirs(directory_path)
        print(f"Directory {directory_path} creata con successo in HDFS.")
    except Exception as e:
        print(f"Errore durante la creazione della directory in HDFS: {e}")

# Specifica il percorso della directory in HDFS
hdfs_directory_path = "/testDirectory"

# Specifica le informazioni di connessione per InsecureClient
hdfs_nameservice = "my_ha_cluster"
hdfs_port = 9820

# Configura l'oggetto InsecureClient con il nameservice
hdfs_client = InsecureClient(
    url=f"http://{hdfs_nameservice}:{hdfs_port}",
    user="root"
)

# Chiama la funzione per creare la directory
create_hdfs_directory(hdfs_client, hdfs_directory_path)
