import sys

args = sys.argv
scene = args[1]

class raytracer:
    fileName = ""
    vertices = []
    ambientMaterial = None
    diffuseMaterial = None
    specularMaterial = None
    transmissiveMaterial = None
    spheres = []
    triangles = []
    planes = []
    pointLight = None
    directionalLight = None
    spotLight = None
    ambientLight = None
    camera = None
    imageResolution = []
    outputImage = ""
    background = None
    recursionDepth = None

    def __init__(self,scene):
        self.fileName = scene

    def parseFile(self):

        file = open(self.fileName)

        for line in file:

        args = line.strip('\n').split(" ")
        command = args[0]

        if(command == "vv"):
            self.vertices.append([int(args[1]),int(args[2]),int(args[3]),int(args[4]),int(args[5]),int(args[6])])
        elif(command == "am"):
            pass
        elif(command == "dm"):
            pass        
        elif(command == "sm"):
            pass        
        elif(command == "tm"):
            pass        
        elif(command == "ss"):
            pass        
        elif(command == "ts"):
            pass        
        elif(command == "ps"):
            pass        
        elif(command == "pl"):
            pass        
        elif(command == "dl"):
            pass        
        elif(command == "sl"):
            pass        
        elif(command == "al"):
            pass        
        elif(command == "cc"):
            pass        
        elif(command == "ir"):
            pass        
        elif(command == "out"):
            pass
        elif(command == "back"):
            pass        
        elif(command == "rdepth"):
            pass            
        else:
            pass
#Comments

trace = raytracer(scene)
trace.parseFile()
print trace.vertices
