import Image
import sys
import math
import numpy
import random
import time

args = sys.argv
scene = args[1]

class Light:

	value = []

	def __init__(self,value):
		self.value = value

class Point(Light):

	position = None
	normal = None

	def __init__(self,value,p,n):
		self.value = value
		self.position = p
		self.normal = n

class Directional(Light):

	position = None
	normal = None

	def __init__(self,value,p,n):
		self.value = value
		self.position = p
		self.normal = n

class Spot(Light):

	position = None
	normal = None

	def __init__(self,value,p,n):
		self.value = value
		self.position = p
		self.normal = n

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
	position = None
	normal = None
	ambientMaterial = None
	diffuseMaterial = None
	specularMaterial = None
	transmissiveMaterial = None

	def __init__(self,p,n,am,dm,sm,tm):
		self.position = p
		self.normal = n
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

	position = None
	normal = None
	fustrum = None

	def __init__(self,p,n,f=30):
		self.position = p
		self.normal = n
		self.fustrum = f

class Ray:

	position = None
	vector = None

	def __init__(self,p,v):
		self.position = p
		self.vector = v

class Raytracer:
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
				self.spheres.append( Sphere(self.vertices[int(args[1])].position,self.vertices[int(args[1])].normal,self.ambientMaterial,self.diffuseMaterial,self.specularMaterial,self.transmissiveMaterial) )        
			#Triangle - i j k
			elif(command == "ts"):
				pass        
			#Plane - i
			elif(command == "ps"):
				pass        
			#Point Light - i r g b
			elif(command == "pl"):
				self.lights.append( Point(self.vertices[int(args[1])].position,self.vertices[int(args[1])].normal,[float(args[2]), float(args[3]), float(args[4])]) )
			#Directional Light - i r g b
			elif(command == "dl"):
				self.lights.append( Directional(self.vertices[int(args[1])].position,self.vertices[int(args[1])].normal,[float(args[2]), float(args[3]), float(args[4])]) )
			#Spot Light - i r g b
			elif(command == "sl"):
				self.lights.append( Spot(self.vertices[int(args[1])].position,self.vertices[int(args[1])].normal,[float(args[2]), float(args[3]), float(args[4])]) )
			#Ambient Light - r g b
			elif(command == "al"):
				self.lights.append( lAmbient([float(args[1]), float(args[2]), float(args[3])]) )
			#Camera - i
			elif(command == "cc"):
				self.camera = Camera(self.vertices[int(args[1])].position,self.vertices[int(args[1])].normal)      
			#Image Resolution - w h
			elif(command == "ir"):
				self.imageResolution = [int(args[1]),int(args[2])]
			#Out Image - filename
			elif(command == "out"):
				self.outputImage = args[1]
			#Background - r g b
			elif(command == "back"):
				self.background = (int(args[1]), int(args[2]), int(args[3]))
			#Recursion Depth - n
			elif(command == "rdepth"):
				self.recursionDepth = int(args[1])
			#Comments
			else:
				pass

	def sub(self, v1, v2): 
		return [x-y for x,y in zip(v1, v2)]

	def dot(self, v1, v2): 
		return sum([x*y for x,y in zip(v1, v2)])

	def norm(self, v): 
		return [x/math.sqrt(self.dot(v,v)) for x in v]

	def doIt(self):
		start = int(round(time.time() * 1000))
		width = self.imageResolution[0]
		height = self.imageResolution[1]
		image = Image.new("RGB", (width,height))
		pixels = image.load()
		camera = self.camera
		# ray = ( (0,0,0), self.norm(((0-width/2.0)/width, (0-height/2.0)/width, 1)) )
		# pixels[0,0] = self.trace_ray(ray, spheres)

		for x in range(width):
			for y in range(height):

				# RIGHT, LEFT, TOP, BOTTOM. center of image x-y plane is 0,0.
				r = width/2
				l = -1 * r
				t = height/2
				b = -1 * t

				# U, V = co-ordinates on image frame plane for ray to cast thru
				u = l + (r - l)*(x + .5)/width
				v = b + (t - b)*(y + .5)/height

				# camera frustum / 2 is the angle used in calculating distance to frame
				theta = camera.fustrum/2

				# D = distance to frame
				d = width/(2*math.tan(theta))

				# direction vector of camera (unit)
				look = self.norm(camera.normal[:])
				# up is always <0,1,0>, unit
				up = [0,1,0]

				# right vector is perpendicular to up, look
				right = [(look[1] * up[2]) - (up[1] * look[2]),
						 (look[2] * up[0]) - (up[2] * look[0]),
						 (look[0] * up[1]) - (up[0] * look[1])]

				# scale the look vector by distance
				look[0] *= d
				look[1] *= d
				look[2] *= d

				# scale right vector by V coord
				right[0] *= v
				right[1] *= v
				right[2] *= v

				# scale up vector by U coord
				up = [0,u,0]

				# ray direction vector is all these combined
				rayDirection = [look[0] + up[0] + right[0],
								look[1] + up[1] + right[1],
								look[2] + up[2] + right[2]]

				# turn into python ray
				ray = Ray( camera.position, rayDirection )
				
				result = self.traceRay(ray,lights)

				pixels[x,y] = result


		image.save(self.outputImage + ".gif")
		end = int(round(time.time() * 1000)) - start
		print end

	def traceRay(self,ray,lights):
		results = []
		for s in self.spheres:
			# mat = s.ambientMaterial.value
			# results.append((self.traceSphere(ray, s), (int(mat[0]*255),int(mat[1]*255),int(mat[2]*255))))

			t = self.traceSphere(ray,s)

			pointOnSphere = ray.position[:]

			pointOnSphere[0] += ray.vector[0] * t
			pointOnSphere[1] += ray.vector[1] * t
			pointOnSphere[2] += ray.vector[2] * t

			pointNormal = pointOnSphere[:]
			pointNormal[0] -= s.position[0]
			pointNormal[1] -= s.position[1]
			pointNormal[2] -= s.position[2]

			pointLight = None
			for light in lights:
				if light.__class__.__name__ == 'Point':
					pointLight = light
					break

			diffuseRed = s.diffuseMaterial.value[0]
			pixelRed = diffuseRed * pointLight.value[0] * max(0,numpy.dot(pointNormal,pointLight.normal))
			diffuseGreen = s.diffuseMaterial.value[1]
			pixelRed = diffuseRed * pointLight.value[1] * max(0,numpy.dot(pointNormal,pointLight.normal))
			diffuseBlue = s.diffuseMaterial.value[2]
			pixelRed = diffuseRed * pointLight.value[2] * max(0,numpy.dot(pointNormal,pointLight.normal))

		results = filter(lambda tuple: tuple[0], results)
		results = sorted(results, key=lambda tuple: tuple[1])
		if results:
			return results[0][1]
		else:
			return self.background



	def traceSphere(self,ray,sphere):
		e = ray.position
		c = sphere.position
		d = ray.vector

		d = self.norm(d)

		n = sphere.normal
		radius = math.sqrt(n[0]**2 + n[1]**2 + n[2]**2)

		e_minus_c = numpy.subtract(e, c)
		d_dot_d   = numpy.dot(d,d)
		discriminant = (numpy.dot(d,e_minus_c))**2 - ((d_dot_d * (numpy.dot(e_minus_c, e_minus_c)-radius**2)))


		if discriminant >= 0:

			neg_d = []
			for i in range(len(d)):
				neg_d.append(d[i]*-1)

			t_plus  = (numpy.dot(neg_d,e_minus_c) + discriminant)/d_dot_d
			t_minus = (numpy.dot(neg_d,e_minus_c) - discriminant)/d_dot_d

			return min(t_plus,t_minus)
		else:	
			return False


trace = Raytracer(scene)
trace.parseFile()
trace.doIt()
# for v in trace.vertices:
# 	print v.position

# print "---------------"

# for s in trace.spheres:
# 	print s.position
# 	print s.normal
# 	print s.ambientMaterial.value
