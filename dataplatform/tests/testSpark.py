import sys
from operator import add
import os
import sys
import time
from dotenv import load_dotenv
from pyspark.sql import SparkSession
from pyspark import SparkConf

path1 = "../.testEnv"
path2 = ".testEnv"
if os.path.isfile(path1):
    load_dotenv(path1)
elif os.path.isfile(path2):
    load_dotenv(path2)

#os.environ['PYSPARK_PYTHON'] = sys.executable
#os.environ['PYSPARK_DRIVER_PYTHON'] = sys.executable

conf = SparkConf()
spark = SparkSession\
    .builder\
    .appName("PythonWordCount")\
    .getOrCreate()

print("Builded a spark session")

# Definisci la stringa da cui creare l'RDD
input_string = """
In una notte stellata, nel cuore di una vasta foresta, c'era un antico castello avvolto nel mistero. Questo castello, noto come Castello delle Ombre, era da tempo abbandonato e considerato infestato da creature soprannaturali.

Le pareti del castello erano rivestite di rampicanti e muschio, e le finestre erano rotte e spesso coperte da ragnatele. Nonostante il suo aspetto inquietante, il castello aveva una storia affascinante che attraeva avventurieri e cercatori di tesori da ogni parte del mondo.

Molti raccontavano storie di visioni spettrali e suoni inquietanti provenienti dal castello durante le notti senza luna. Alcuni osavano entrare, ma pochi tornavano indietro per raccontare ciò che avevano visto.

La leggenda diceva che il castello contenesse un tesoro nascosto di inestimabile valore, ma nessuno sapeva esattamente dove si trovasse o chi lo aveva nascosto. Le storie sul tesoro perduto erano passate di generazione in generazione, alimentando il desiderio di coloro che cercavano fama e fortuna.

Un giorno, un giovane esploratore di nome Edward decise di intraprendere l'ardua impresa di esplorare il Castello delle Ombre. Aveva letto storie sul tesoro fin dall'infanzia e sentiva che era giunto il momento di scoprire la verità.

Con una torcia in una mano e una mappa scritta a mano nell'altra, Edward si avventurò nell'oscurità del castello. Ogni passo era accompagnato da un sussurro del vento e da strani rumori provenienti dalle stanze oscure.

Man mano che esplorava il castello, Edward trovò antiche stanze segrete, corridoi misteriosi e porte bloccate. La sua determinazione non vacillò, e continuò a cercare il tesoro nascosto.

Le sue avventure lo portarono attraverso intricati puzzle e trappole mortali. Tuttavia, Edward non si arrese. Alla fine, dopo giorni di esplorazione, fece una scoperta straordinaria.

Nel cuore del castello, trovò una camera segreta con una grande cassa. Con il cuore che batteva velocemente, aprì la cassa e vide scintillare gioielli, monete d'oro e oggetti di inestimabile bellezza.

Edward aveva finalmente trovato il tesoro del Castello delle Ombre. Il suo cuore era pieno di gioia mentre guardava la ricchezza di fronte a lui. Ma sapeva che il tesoro aveva portato sventura a molti, e decise di condividere la sua scoperta con il mondo anziché tenerla solo per sé.

Le notizie del tesoro scoperto si diffusero velocemente, e il Castello delle Ombre divenne un luogo di pellegrinaggio per cercatori di tesori e curiosi. La ricchezza del castello cambiò la vita di molti e portò nuova vita alla leggenda del Castello delle Ombre.

Così, il mistero del castello e il suo tesoro nascosto continuarono a ispirare le generazioni future, dimostrando che anche nelle ombre più profonde può risplendere la luce della speranza.
"""
input_string = input_string.replace("\t", " ")

file_path = f"word_count.txt"
output_path = f"testSpark/"

rdd = spark.sparkContext.parallelize([input_string])

rdd.coalesce(1).saveAsTextFile(output_path+"word_count.txt")
# Specifica il percorso del file da verificare
print("Successfully saved file")

#print(file_path)
# Leggi il file da HDFS
lines = spark.read.text(output_path+file_path).rdd.map(lambda x: x[0])

try:
  print("Successfully read text")
  counts = lines.flatMap(lambda x: x.split(' ')) \
                .map(lambda x: (x, 1)) \
                .reduceByKey(add)
  output = counts.collect()
  
  counts.saveAsTextFile(output_path+"output/")
 
  spark.stop()
  print("Execution went just fine")
except Exception as e:
  print("Something went wrong while executing script...")
  print(e)
