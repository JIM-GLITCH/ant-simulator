from threading import Thread
import subprocess

mapnumber=3
antComAlgorithm=1
numAnts=25
mapMaxX =1600
mapMaxY =320
TEST="movefood"
def run_one_test(trial,mapnumber,antComAlgorithm,numAnts,mapMaxX,mapMaxY,TEST):
    print("map {} algrithm {} test {}: running..".format(mapnumber,antComAlgorithm,trial))
    taskFinishedTime=subprocess.call(['love','./', str(mapnumber),str(antComAlgorithm),str(numAnts),str(mapMaxX),str(mapMaxY),TEST ,str(trial)], shell=True)
    # with open("map{}_algorithm{}_ants{}.txt".format(mapnumber,antComAlgorithm,numAnts),'a') as f:
    #     f.write('{}\n'.format(taskFinishedTime))
    return taskFinishedTime 

def run_thread(mapMaxX,mapMaxY,numAnts):
    for trial in range(1,10):
            run_one_test(trial,mapnumber,antComAlgorithm,numAnts,mapMaxX,mapMaxY,TEST)

for mapMaxX,mapMaxY   in [(640,320)]:
    for numAnts in [100,200,400,800]:
        a_thread=Thread(target=run_thread,args=[mapMaxX,mapMaxY,numAnts])
        a_thread.start()

        # for trial in range(1,10):
        #     a=Thread(target=run_one_test,args=(trial,mapnumber,antComAlgorithm,numAnts,mapMaxX,mapMaxY,TEST))
        #     a.start()