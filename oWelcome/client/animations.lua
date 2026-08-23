--[[ oWelcome — tweens e easings ]]

WelcomeAnim = WelcomeAnim or {}

function WelcomeAnim.easeOutCubic(t)
	t = math.max(0, math.min(1, t))
	return 1 - math.pow(1 - t, 3)
end

function WelcomeAnim.easeOutQuad(t)
	t = math.max(0, math.min(1, t))
	return 1 - (1 - t) * (1 - t)
end

function WelcomeAnim.lerp(a, b, t)
	return a + (b - a) * t
end

function WelcomeAnim.smoothToward(current, target, dt, speed)
	speed = speed or 14
	local k = math.min(1, dt * speed)
	return WelcomeAnim.lerp(current, target, k)
end
