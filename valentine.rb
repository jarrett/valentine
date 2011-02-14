require 'rubygems'
require 'RMagick'
require 'base64'
require 'digest'

class Valentine
	# Configuration parameters for the output image
	OUTFILE = 'valentine.png'
	MESSAGE_1_64 = 'SGFwcHkgVmFsZW50aW5lJ3MgRGF5IQ=='
	MESSAGE_2_64 = 'TG92ZSwgSmFycmV0dA=='
	COLOR = '#ff0000'
	CIRCLE_COUNT = 80
	BASE_X = 300 # X coord of the base circle's center
	BASE_Y = 180 # Y coord of the base circle's center
	BASE_RAD = 90 # Radius of the base circle
	CORRECT_MD5 = '2a5868cae248176c48ecc7ec5b867131'
	
	# Read the rendered image into memory, compute its MD5 hash, and check it against
	# the known, correct hash (CORRECT_MD5).
	def check_for_correct_output
		if Digest::MD5.hexdigest(File.read(OUTFILE)) == CORRECT_MD5
			puts 'Output is correct!'
		else
			puts 'Output is incorrect. Continue debugging.'
		end
	end
	
	# Draw an envelope from a set of circles using a base circle as a guide.
	# Each circle in the set has the following properties:
	#
	# - Its center lies on the circumference of the base circle.
	# - It passes through the highest point (i.e. 12 o'clock) on the base circle.
	#
	# The set of all such circles has infinite members, of course. But for our purposes,
	# we'll approximate the envelope by drawing an arbitrary, finite number of them.
	# That number if CIRCLE_COUNT.
	#
	# If you want to temporarily modify any of the constants we use, that's fine,
	# but be sure to change them back. Otherwise, #check_for_correct_output will never pass.
	#
	# http://en.wikipedia.org/wiki/Envelope_(mathematics)
	def draw_envelope
		degrees_offset_per_circle = 360.to_f / CIRCLE_COUNT
		CIRCLE_COUNT.times do |circle_index|
			# Draw a circle in the set.
			line_art = Magick::Draw.new # Initialize a Magick::Draw instance, which handles line drawing
			line_art.fill = 'none'
			line_art.stroke(COLOR)
			x, y = point_on_base_circle(degrees_offset_per_circle * circle_index)
			radius = radius_from(x, y)
			line_art.circle(x, y, x + radius, y) # Draw a circle into the buffer
			line_art.draw(@image) # Write the contents of the buffer onto the final image
		end
	end
	
	def generate
		@image = Magick::Image.new(600, 600) do
			self.background_color = 'black'
		end
		write_text
		draw_envelope
		write_to_file
		check_for_correct_output
	end
	
	# Return an array of the form [x_coord, y_coord] representing a point on the base circle
	# at the given number of degrees.
	def point_on_base_circle(degrees)
		radians = degrees * (Math::PI / 180)
		[
			BASE_X + (BASE_RAD * Math.cos(radians)),
			BASE_Y + (BASE_RAD * Math.sin(radians))
		]
		#raise 'Valentine#point_on_base_circle is not implemented. Please write this method.'
	end
	
	# Compute the radius of a circle in the set with center at (x, y).
	def radius_from(x, y)
		apex_x = BASE_X
		apex_y = BASE_Y - BASE_RAD
		dx = x - apex_x
		dy = y - apex_y
		Math.sqrt(dx**2 + dy**2)
		#raise 'Valentine#radius_from is not implemented. Please write this method.'
		# Hint: This should be computed based on the assumption that the resulting
		# circle must pass through 12 o'clock on the base circle.
	end
	
	# Write a message on the image
	def write_text
		text = Magick::Draw.new
		text.font_family = 'georgia'
		text.font_weight = Magick::NormalWeight
		text.pointsize = 40
		text.fill = COLOR
		text.gravity = Magick::SouthGravity
		text.annotate(@image, 0, 0, 0, 60, Base64.decode64(MESSAGE_1_64))
		text.pointsize = 20
		text.annotate(@image, 0, 0, 0, 20, Base64.decode64(MESSAGE_2_64))
	end
	
	def write_to_file
		@image.write(OUTFILE)
		puts 'Output image written to ' + OUTFILE
	end
end

Valentine.new.generate