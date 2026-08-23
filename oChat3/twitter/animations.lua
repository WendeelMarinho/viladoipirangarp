--[[ Ipiranga Tweets — animação ]]

TwAnim = TwAnim or {}

function TwAnim.lerp(a, b, t)
	return a + (b - a) * t
end

function TwAnim.easeOut(t)
	t = math.max(0, math.min(1, t))
	return 1 - (1 - t) * (1 - t)
end
