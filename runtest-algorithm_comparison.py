from threading import Thread
import subprocess
#----------------------------------------------------------------------------------------#
# default arguments
mapnumber=3
antComAlgorithm=1
numAnts=25
mapMaxX =1600
mapMaxY =320
#----------------------------------------------------------------------------------------#



def run_one_test(trial,mapnumber,antComAlgorithm,numAnts,mapMaxX,mapMaxY,TEST,antPositionMemorySize):
    print("map {} algrithm {} test {}: running..".format(mapnumber,antComAlgorithm,trial))
    taskFinishedTime=subprocess.call(['love','./', str(mapnumber),
                                                   str(antComAlgorithm),
                                                   str(numAnts),
                                                   str(mapMaxX),
                                                   str(mapMaxY),
                                                   TEST ,
                                                   str(trial),
                                                   str(antPositionMemorySize)
                                                   ],shell=True)
    # with open("map{}_algorithm{}_ants{}.txt".format(mapnumber,antComAlgorithm,numAnts),'a') as f:
    #     f.write('{}\n'.format(taskFinishedTime))
    return taskFinishedTime 

def run_thread(antComAlgorithm,mapMaxX,mapMaxY,numAnts,antPositionMemorySize):
    for trial in range(1,10):
            run_one_test(trial,mapnumber,antComAlgorithm,numAnts,mapMaxX,mapMaxY,TEST,antPositionMemorySize)

#----------------------------------------------------------------------------------------#
            
TEST="algorithm_comparison"
mapMaxX,mapMaxY=(640,320)
numAnts =200
antPositionMemorySize=15

for antComAlgorithm in [1,3]:
    a_thread=Thread(target=run_thread,args=[antComAlgorithm,mapMaxX,mapMaxY,numAnts,antPositionMemorySize])
    a_thread.start()
