XSVolumetrics is a package for simple Volumetric Lighting effects, made in the same way as those found in the newer World of Warcraft expansions.

This method does hold up well in VR.

Example of it in actions.

![](https://i.imgur.com/nFHRtNf.jpg)


Please note, if you want to make sure you don't see clipping on the edges of the mesh where it intersects, you will need to enable the depth buffer in your scene. 

One of the ways you can do this is with post processing, or, a directional light.  

For a Directional light, use these settings exactly to have the least impact on performance. If you do not follow this, your performance could possibly suffer.

![](https://i.imgur.com/Bc1Wou8.jpg)


For post processing, the best way is to enable Depth of Field, and then use these settings. This forces the depth buffer on, but insures that you don't actually have any of that pesky DoF effect in VR. (Please don't actually use DoF in VR.)

![](https://i.imgur.com/HodHHhD.jpg) 
