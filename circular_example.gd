extends Control

@export var audio_player: AudioStreamPlayer
var fft_size := 512
var sample_rate := 1000  # Adjusted for proper FFT range handling
var frequencies = []
var smoothed_frequencies = []
var max_amplitude = 1
@export var shuffle_freq = false
@onready var spectrum = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Visualizer"), 0)

var color_gradient := Gradient.new()  # Dynamic color transitions

func _ready():

	# Set up color gradient (Blue → Purple → Red)
	color_gradient.add_point(0.0, Color(0.2, 1.0, 0.8))  # Cyan
	color_gradient.add_point(0.5, Color(0.6, 0.2, 1.0))  # Purple
	color_gradient.add_point(1.0, Color(1.0, 0.2, 0.2))  # Red

	# Initialize smoothed frequencies
	smoothed_frequencies.resize(fft_size / 2)
	smoothed_frequencies.fill(0.0)

func _process(_delta):
	if spectrum:
		frequencies.clear()
		for i in range(fft_size / 2):
			var min_freq = i * sample_rate / fft_size
			var max_freq = (i+1) * sample_rate / fft_size
			var magnitude = spectrum.get_magnitude_for_frequency_range(min_freq, max_freq).length()
			frequencies.append(magnitude / max_amplitude)  # Normalize

			# Smooth out frequencies using linear interpolation
		if shuffle_freq:
			frequencies.shuffle()
		for i in range(fft_size / 2):	
			smoothed_frequencies[i] = lerp(smoothed_frequencies[i], frequencies[i], 0.1)
	
	queue_redraw()

func _draw():
	if frequencies.is_empty():
		return
	
	var center = get_viewport_rect().size / 2
	var radius = 10
	var segments = frequencies.size()

	# Find the highest frequency amplitude for better color mapping
	var max_freq_amp = smoothed_frequencies.max()

	for i in range(segments):
		var angle = i * TAU / segments
		var amp = smoothed_frequencies[i] * 1000  # Scale visualization
		var start = center + Vector2(radius, 0).rotated(angle)
		var end = center + Vector2(radius + (amp*6), 0).rotated(angle)

		# Normalize frequency amplitude for color gradient (0.0 to 1.0)
		var intensity = amp / (max_freq_amp * 1000.0) if max_freq_amp > 0 else 0.0
		intensity = clamp(intensity, 0.0, 1.0)  # Keep within valid range

		# Get dynamic color from gradient
		var color = color_gradient.sample(intensity)

		draw_line(start, end, color, 3)


