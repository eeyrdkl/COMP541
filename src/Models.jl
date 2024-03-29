include("Layers.jl")

#3D Feature Vector : Output size (4096,1)
@knet function ORNFeature(x)
	w=par(init=ORNWeights["conv1_w"], dims=(5,5,5,3,96))
	b=par(init=ORNWeights["conv1_b"], dims=(1,1,1,96))
	y=conv(w,x; window=5, padding=1, stride=1)
	y=relu(y.+b)
	y=pool(y; window=2, padding=0, stride=2)

	w=par(init=ORNWeights["conv2_w"], dims=(3,3,3,96,192))
	b=par(init=ORNWeights["conv2_b"], dims=(1,1,1,192))
	y=conv(w,y; window=3, stride=1)
	y=relu(y.+b)
	y=pool(y; window=2, stride=2)

	w=par(init=ORNWeights["conv3_w"], dims=(3,3,3,192,384))
	b=par(init=ORNWeights["conv3_b"], dims=(1,1,1,384))
	y=conv(w,y; window=3, stride=1)
	y=relu(y.+b)

	w=par(init=ORNWeights["fc4_w"], dims=(4096,24576))
	b=par(init=ORNWeights["fc4_b"], dims=(4096,1))
	y=relu(w*y.+b)

	return dropout(y)
end

#19 Layer VGGNet
#2D Feature Vector : Output size (1,1,4096,1)
@knet function VGGNet19(x)
	y=VGGNetConv(x; inc=3, outc=64, winit=VGGWeights19["conv1_1_w"], binit=VGGWeights19["conv1_1_b"])
	y=VGGNetConv(y; inc=64, outc=64, winit=VGGWeights19["conv1_2_w"], binit=VGGWeights19["conv1_2_b"])
	y=pool(y)

	y=VGGNetConv(y; inc=64, outc=128, winit=VGGWeights19["conv2_1_w"], binit=VGGWeights19["conv2_1_b"])
	y=VGGNetConv(y; inc=128, outc=128, winit=VGGWeights19["conv2_2_w"], binit=VGGWeights19["conv2_2_b"])
	y=pool(y)

	y=VGGNetConv(y; inc=128, outc=256, winit=VGGWeights19["conv3_1_w"], binit=VGGWeights19["conv3_1_b"])
	y=VGGNetConv(y; inc=256, outc=256, winit=VGGWeights19["conv3_2_w"], binit=VGGWeights19["conv3_2_b"])
	y=VGGNetConv(y; inc=256, outc=256, winit=VGGWeights19["conv3_3_w"], binit=VGGWeights19["conv3_3_b"])
	y=VGGNetConv(y; inc=256, outc=256, winit=VGGWeights19["conv3_4_w"], binit=VGGWeights19["conv3_4_b"])
	y=pool(y)

	y=VGGNetConv(y; inc=256, outc=512, winit=VGGWeights19["conv4_1_w"], binit=VGGWeights19["conv4_1_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights19["conv4_2_w"], binit=VGGWeights19["conv4_2_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights19["conv4_3_w"], binit=VGGWeights19["conv4_3_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights19["conv4_4_w"], binit=VGGWeights19["conv4_4_b"])
	y=pool(y)
	
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights19["conv5_1_w"], binit=VGGWeights19["conv5_1_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights19["conv5_2_w"], binit=VGGWeights19["conv5_2_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights19["conv5_3_w"], binit=VGGWeights19["conv5_3_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights19["conv5_4_w"], binit=VGGWeights19["conv5_4_b"])
	y=pool(y)

	#FC to generate 4096 feature vector
	return VGGNetConv(y; inc=512, outc=4096, winit=VGGWeights19["fc6_w"], binit=VGGWeights19["fc6_b"], wnd=7, pad=0)
end

#16 Layer VGGNet
#2D Feature Vector : Output size (1,1,4096,1)
@knet function VGGNet16(x)
	y=VGGNetConv(x; inc=3, outc=64, winit=VGGWeights16["conv1_1_w"], binit=VGGWeights16["conv1_1_b"])
	y=VGGNetConv(y; inc=64, outc=64, winit=VGGWeights16["conv1_2_w"], binit=VGGWeights16["conv1_2_b"])
	y=pool(y)

	y=VGGNetConv(y; inc=64, outc=128, winit=VGGWeights16["conv2_1_w"], binit=VGGWeights16["conv2_1_b"])
	y=VGGNetConv(y; inc=128, outc=128, winit=VGGWeights16["conv2_2_w"], binit=VGGWeights16["conv2_2_b"])
	y=pool(y)

	y=VGGNetConv(y; inc=128, outc=256, winit=VGGWeights16["conv3_1_w"], binit=VGGWeights16["conv3_1_b"])
	y=VGGNetConv(y; inc=256, outc=256, winit=VGGWeights16["conv3_2_w"], binit=VGGWeights16["conv3_2_b"])
	y=VGGNetConv(y; inc=256, outc=256, winit=VGGWeights16["conv3_3_w"], binit=VGGWeights16["conv3_3_b"])
	y=pool(y)

	y=VGGNetConv(y; inc=256, outc=512, winit=VGGWeights16["conv4_1_w"], binit=VGGWeights16["conv4_1_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights16["conv4_2_w"], binit=VGGWeights16["conv4_2_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights16["conv4_3_w"], binit=VGGWeights16["conv4_3_b"])
	y=pool(y)
	
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights16["conv5_1_w"], binit=VGGWeights16["conv5_1_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights16["conv5_2_w"], binit=VGGWeights16["conv5_2_b"])
	y=VGGNetConv(y; inc=512, outc=512, winit=VGGWeights16["conv5_3_w"], binit=VGGWeights16["conv5_3_b"])
	y=pool(y)

	#FC to generate 4096 feature vector
	return VGGNetConv(y; inc=512, outc=4096, winit=VGGWeights16["fc6_w"], binit=VGGWeights16["fc6_b"], wnd=7, pad=0)
end

@knet function ORNClass(v2d, v3d)
	#Simulate concatenation and reduce dimension to 1000
	w=par(init=ORNWeights["fc5_w"], dims=(1000, 4096))
	b=par(init=ORNWeights["fc5_b"], dims=(1000,1))

	y2d=w*v2d.+b
	y3d=w*v3d.+b
	v=relu(y3d+y2d)
	v=dropout(v)

	#Classify
	return softmax(v; num=20, winit=ORNWeights["fc_cls_w"], binit=ORNWeights["fc_cls_b"])
end
