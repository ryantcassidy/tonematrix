import Image
import sys
import math
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

	def __init__(self,p,n,value):
		self.value = value
		self.position = p
		self.normal = n

class Directional(Light):
	position = None
	normal = None

	def __init__(self,p,n,value):
		self.position = p
		self.normal = n
		self.value = value

class Spot(Light):
	position = None
	normal = None

	def __init__(self,p,n,value):
		self.value = value
		self.position = p
		self.normal = n

class lAmbient(Light):
	value = []

	def __init__(self,value):
		self.value = value

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

	def __init__(self,p,n,f=math.pi/3):
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
	ambientLight = None
	diffuseMaterial = Diffuse()
	specularMaterial = Specular()
	transmissiveMaterial = Transmissive()
	spheres = []
	triangles = []
	planes = []
	ambientLight = None
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
				self.lights.append( Point(self.vertices[int(args[1])].position,
										  self.vertices[int(args[1])].normal,
										  [float(args[2]), float(args[3]), float(args[4])]) )
			#Directional Light - i r g b
			elif(command == "dl"):
				self.lights.append( Directional(self.vertices[int(args[1])].position,
												self.vertices[int(args[1])].normal,
												[float(args[2]), float(args[3]), float(args[4])]) )
			#Spot Light - i r g b
			elif(command == "sl"):
				self.lights.append( Spot(self.vertices[int(args[1])].position,
										 self.vertices[int(args[1])].normal,
										 [float(args[2]), float(args[3]), float(args[4])]) )
			#Ambient Light - r g b
			elif(command == "al"):
				self.ambientLight = lAmbient([float(args[1]), float(args[2]), float(args[3])]) 

			#Camera - i
			elif(command == "cc"):
				self.camera = Camera(self.vertices[int(args[1])].position,
									 self.vertices[int(args[1])].normal)      
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

	def add(self, v1, v2): 
		return [x+y for x,y in zip(v1, v2)]

	def dot(self, v1, v2): 
		return sum([x*y for x,y in zip(v1, v2)])

	def norm(self, v): 
		return [x/math.sqrt(self.dot(v,v)) for x in v]

	def cross(self, v1, v2):
		return [v1[1] * v2[2] - v2[1] * v1[2],
		        v1[2] * v2[0] - v2[2] * v1[0],
						v1[0] * v2[1] - v2[0] * v1[1]]

	def scale(self, vec, scalar):
		return [x * scalar for x in vec]

	def trace(self):
		# time things!
		start = int(round(time.time() * 1000))
		# image width / height
		width = self.imageResolution[0]
		height = self.imageResolution[1]
		image = Image.new("RGB", (width,height))
		pixels = image.load()

		camera = self.camera

		# FOR EACH PIXEL: CAST A RAY (pew pew!)
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
				# print "U:  " + str(u)
				# print "V:  " + str(v)

				# camera frustum / 2 is the angle used in calculating distance to frame
				theta = camera.fustrum/2

				# D = distance to frame
				d = width/(2*math.tan(theta))

				# up is always <0,1,0>, unit
				up_v = [0,1,0]

				# direction vector of camera (unit) = -W
				# Create orthonormal basis based on camera
				W = self.norm(camera.normal[:])
				U = self.norm(self.cross(up_v, W))
				V = self.cross(W, U)

				# scale the look vector by distance
				look = self.scale(W[:], d)

				# scale right vector by V coord
				right = self.scale(U[:], u)

				# scale up vector by U coord
				up = self.scale(V[:], v)

				# ray direction vector is all these combined
				# -w * d + up * U + right * V
				rayDirection = [look[0] + up[0] + right[0],
								look[1] + up[1] + right[1],
								look[2] + up[2] + right[2]]

				# turn into python ray
				ray = Ray( camera.position, rayDirection )
				
				# trace the ray
				result = self.traceRay(ray)
				pixels[x,y] = result

		image.save(self.outputImage + str(start) + ".gif")
		end = int(round(time.time() * 1000)) - start
		print end

	def traceRay(self,ray):
		results = []

		# for every sphere
		for s in self.spheres:
			results.append(self.traceSphere(ray,s))
			# get rid of false results, sort by T distance

		f_results = filter(None, results)
		s_results = sorted(f_results, key=lambda duple: duple[0])

	  # We now know which sphere is being hit by this ray, and how far away it is.
		# If we hit one...
		if s_results:
		  # s = sphere, t = scale factor for ray vec
			s = s_results[0][1]
			t = s_results[0][0]
			return self.calculateLighting(ray, s, t)
		else:
			return self.background
	def traceShadow(self,ray):
		results = []

		# for every sphere
		for s in self.spheres:
			results.append(self.traceSphere(ray,s))
			# get rid of false results, sort by T distance

		f_results = filter(None, results)
		s_results = sorted(f_results, key=lambda duple: duple[0])
	  # We now know which sphere is being hit by this ray, and how far away it is.

		# If we hit one...
		if s_results:
		  # s = sphere
			s = s_results[0][1]
			t = s_results[0][0]
			return (t,s)
		else:
			return False

	def calculateLighting(self, ray, s, t):
		surfaceNormal = None
		viewDirection = None

		# rayVector = unit vector in direction of casted ray
		rayVector = self.norm(ray.vector)
		# POS = collision point on the sphere with the raycasting results
		pointOnSphere = self.add(ray.position[:], self.scale(rayVector, t))
		# Surface Normal = Unit Vector perpendicular to surface of sphere at this point
		surfaceNormal = self.norm(self.sub(pointOnSphere[:], s.position))

	  # Base Pixel Vals
		pointLight = None
		pixelRed   = s.ambientMaterial.value[0] * self.ambientLight.value[0]
		pixelGreen = s.ambientMaterial.value[1] * self.ambientLight.value[1]
		pixelBlue  = s.ambientMaterial.value[2] * self.ambientLight.value[2]

		for light in self.lights:
			lightDirection = None
			if light.__class__.__name__ == 'Point':
				pointLight = light


				# Light Direction - unit vector starting from Point ON Sphere in direction of light
				lightDirection = self.norm(self.sub(pointLight.position[:], pointOnSphere))

				lightDirectionTowardsPOS = self.scale(lightDirection,-1)

				shadow = self.traceShadow(Ray(pointLight.position,lightDirectionTowardsPOS))
				if shadow and shadow[1] == s:

					# View Direction  - unit vector starting from point on sphere to the camera
					viewDirection = self.norm(self.sub(ray.position, pointOnSphere))
					# Half Vector = Addition of View and Light direction
					halfVector = self.norm(self.add(viewDirection,lightDirection))
					
					# Avoid repetition of vector math
					n_dot_h = self.dot(surfaceNormal, halfVector)
					n_dot_l = self.dot(surfaceNormal, lightDirection)

					# Pixel Values
					specularRed = s.specularMaterial.value[0] * pointLight.value[0] * max(0,n_dot_h)**s.specularMaterial.value[3]
					diffuseRed  = s.diffuseMaterial.value[0] * pointLight.value[0] * max(0,n_dot_l)
		
					specularGreen = s.specularMaterial.value[1] * pointLight.value[1] * max(0,n_dot_h)**s.specularMaterial.value[3]
					diffuseGreen  = s.diffuseMaterial.value[1] * pointLight.value[1] * max(0,n_dot_l)

					specularBlue = s.specularMaterial.value[2] * pointLight.value[2] * max(0,n_dot_h)**s.specularMaterial.value[3]
					diffuseBlue  = s.diffuseMaterial.value[2] * pointLight.value[2] * max(0,n_dot_l) 

					# Add light values to ambient vals
					pixelRed   += diffuseRed + specularRed
					pixelGreen += diffuseGreen + specularGreen
					pixelBlue  += diffuseBlue + specularBlue

			elif light.__class__.__name__ == 'Directional':

				directionalLight = light
				# Light Direction - unit vector starting from Point ON Sphere in direction of light
				lightDirection = self.scale(directionalLight.normal,-1)
				shadow = self.traceShadow(Ray(pointOnSphere,lightDirection))
				if shadow and shadow[1] == s:
					# View Direction  - unit vector starting from point on sphere to the camera
					viewDirection = self.norm(self.sub(ray.position, pointOnSphere))
					# Half Vector = Addition of View and Light direction
					halfVector = self.norm(self.add(viewDirection,lightDirection))
					
					# Avoid repetition of vector math
					n_dot_h = self.dot(surfaceNormal, halfVector)
					n_dot_l = self.dot(surfaceNormal, lightDirection)


					# Pixel Values
					specularRed = s.specularMaterial.value[0] * directionalLight.value[0] * max(0,n_dot_h)**s.specularMaterial.value[3]
					diffuseRed  = s.diffuseMaterial.value[0] * directionalLight.value[0] * max(0,n_dot_l)
		
					specularGreen = s.specularMaterial.value[1] * directionalLight.value[1] * max(0,n_dot_h)**s.specularMaterial.value[3]
					diffuseGreen  = s.diffuseMaterial.value[1] * directionalLight.value[1] * max(0,n_dot_l)

					specularBlue = s.specularMaterial.value[2] * directionalLight.value[2] * max(0,n_dot_h)**s.specularMaterial.value[3]
					diffuseBlue  = s.diffuseMaterial.value[2] * directionalLight.value[2] * max(0,n_dot_l) 

					# Add light values to ambient vals
					pixelRed   += diffuseRed + specularRed
					pixelGreen += diffuseGreen + specularGreen
					pixelBlue  += diffuseBlue + specularBlue
		
		colors = (int(pixelRed*255),int(pixelGreen*255),int(pixelBlue*255))
		return colors

	def traceSphere(self,ray,sphere):
		# e = eye, cam pos
		e = ray.position
		# c = sphere center
		c = sphere.position
		# d = unit vector towards image plane
		d = self.norm(ray.vector)

		# n = sphere normal, radius is length
		n = sphere.normal
		radius = math.sqrt(self.dot(n, n))

		# simplify below calculations
		e_minus_c = ( e[0] - c[0], e[1] - c[1], e[2] - c[2] )
		d_dot_d   = self.dot(d,d)

		# discriminant to see if we hit 
		discriminant = (self.dot(d, e_minus_c))**2 - (d_dot_d * (self.dot(e_minus_c, e_minus_c) - (radius**2)))

		if discriminant >= 0:
			neg_d = (-1 * d[0], -1 * d[1], -1 * d[2])

			# Find out results with both values of T
			t_plus  = (self.dot(neg_d,e_minus_c) + math.sqrt(discriminant))/d_dot_d
			t_minus = (self.dot(neg_d,e_minus_c) - math.sqrt(discriminant))/d_dot_d

			# determine min / max
			tmin = min(t_plus,t_minus)
			tmax = max(t_plus,t_minus)
			
			if tmin >= 0:
				return (tmin, sphere)
			elif tmax >= 0:
				return (tmax, sphere)
			else:
				return False
		else:	
			return False

tracer = Raytracer(scene)
tracer.parseFile()
tracer.trace()
# for v in trace.vertices:
# 	print v.position

# print "---------------"

# for s in trace.spheres:
# 	print s.position
# 	print s.normal
 	#print s.ambientMaterial.value
