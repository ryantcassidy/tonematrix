import Image
import sys

args = sys.argv
scene = args[1]

class Light:

    value = []

    def __init__(self,value):
        self.value = value

class Point(Light):

    pass

class Directional(Light):

    pass

class Spot(Light):

    pass
class lAmbient(Light):

    pass

class Material:

    value = []

    def __init__(self,value):
        self.value = value

class mAmbient(Material):

    def __init__(self,value=[0.2, 0.2, 0.2]):
        Material.__init__(self,value)

class Diffuse(Material):

    def __init__(self,value=[1, 1, 1]):
        Material.__init__(self,value)

class Specular(Material):

    def __init__(self,value=[1, 1, 1, 64]):
        Material.__init__(self,value)

class Transmissive(Material):

    def __init__(self,value=[0, 0, 0, 1]):
        Material.__init__(self,value)

class Sphere:
    vertexIndex = None
    ambientMaterial = None
    diffuseMaterial = None
    specularMaterial = None
    transmissiveMaterial = None

    def __init__(self,vi,am,dm,sm,tm):
        self.vertexIndex = vi
        self.ambientMaterial = am
        self.diffuseMaterial = dm
        self.specularMaterial = sm
        self.transmissiveMaterial = tm

class Vertex:

    position = []
    normal = []

    def __init__(self, value):
        self.position = [value[0], value[1], value[2]]
        self.normal   = [value[3], value[4], value[5]]

class Camera:

    vertexIndex = None

    def __init__(self,value):
        self.vertexIndex = value

class raytracer:
    fileName = ""
    vertices = []
    ambientMaterial = mAmbient()
    diffuseMaterial = Diffuse()
    specularMaterial = Specular()
    transmissiveMaterial = Transmissive()
    spheres = []
    triangles = []
    planes = []
    lights = []
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

            #Vertex - x y z dx dy dz
            if(command == "vv"):
                self.vertices.append( Vertex( [float(args[1]),float(args[2]),float(args[3]),float(args[4]),float(args[5]),float(args[6])] ))
            #Ambient Material - r g b 
            elif(command == "am"):
                self.ambientMaterial = mAmbient([float(args[1]), float(args[2]), float(args[3])])
            #Diffuse Material - r g b
            elif(command == "dm"):
                self.diffuseMaterial = Diffuse([float(args[1]), float(args[2]), float(args[3])])
            #Specular Material - r g b n
            elif(command == "sm"):
                self.specularMaterial = Specular([float(args[1]), float(args[2]), float(args[3]), float(args[4])])
            #Transmissive Material - r g b ior
            elif(command == "tm"):
                self.transmissiveMaterial = Transmissive([float(args[1]), float(args[2]), float(args[3]), float(args[4])])
            #Sphere - i
            elif(command == "ss"):
                self.spheres.append( Sphere(int(args[1]),self.ambientMaterial,self.diffuseMaterial,self.specularMaterial,self.transmissiveMaterial) )        
            #Triangle - i j k
            elif(command == "ts"):
                pass        
            #Plane - i
            elif(command == "ps"):
                pass        
            #Point Light - i r g b
            elif(command == "pl"):
                self.lights.append( Point([float(args[1]), float(args[2]), float(args[3]), float(args[4])]) )
            #Directional Light - i r g b
            elif(command == "dl"):
                self.lights.append( Directional([float(args[1]), float(args[2]), float(args[3]), float(args[4])]) )
            #Spot Light - i r g b
            elif(command == "sl"):
                self.lights.append( Spot([float(args[1]), float(args[2]), float(args[3]), float(args[4])]) )
            #Ambient Light - r g b
            elif(command == "al"):
                self.lights.append( lAmbient([float(args[1]), float(args[2]), float(args[3])]) )
            #Camera - i
            elif(command == "cc"):
                self.camera = Camera(int(args[1]))      
            #Image Resolution - w h
            elif(command == "ir"):
                print "IMAGE Resolution"
                self.imageResolution = [int(args[1]),int(args[2])]
            #Out Image - filename
            elif(command == "out"):
                self.outputImage = args[1]
            #Background - r g b
            elif(command == "back"):
                self.background = [int(args[1]), int(args[2]), int(args[3])]
            #Recursion Depth - n
            elif(command == "rdepth"):
                self.recursionDepth = int(args[1])
            else:
                pass
                #Comments

    def doIt(self):
        width = self.imageResolution[0]
        height = self.imageResolution[1]
        image = Image.new("RGB", (width,height))
        image.save(self.outputImage + ".gif")

            


trace = raytracer(scene)
trace.parseFile()
print trace.imageResolution
trace.doIt()
for v in trace.vertices:
    print v.position

print "---------------"

for s in trace.spheres:
    print trace.vertices[s.vertexIndex].position
    print trace.vertices[s.vertexIndex].normal
    print s.ambientMaterial.value