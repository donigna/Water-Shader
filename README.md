
# 🌊 Water System (Unity Built-in Render Pipeline)

![Gerstner Wave](https://github.com/donigna/Water-Shader/blob/main/GerstnerWaterGif.gif?raw=true)

This project implements a **real-time procedural ocean system** using **Gerstner Waves** combined with **fBm noise** to create dynamic and realistic ocean surfaces.  
It includes **buoyancy physics** that allow floating objects to move naturally with the waves.

---

## 🎨 Main Features

- **Gerstner Wave Simulation**  
  Multiple sinusoidal waves with adjustable direction, wavelength, and steepness.

- **fBm Noise Integration**  
  Adds fine surface details for richer and more organic water motion.

- **Dynamic Foam**  
  Foam effect automatically generated based on crest height and surface normals.

- **Reflection & Fresnel Control**  
  Realistic reflections using cubemap sampling and Fresnel blending.

- **Buoyancy Physics**  
  Rigidbody-based floating mechanics that follow the vertical and horizontal wave motion.

---

## ⚙️ Technologies

- **Unity Built-in Render Pipeline**
- **Custom Surface Shader (CGPROGRAM)**
- **C# Runtime Controller** for wave management and buoyancy
- **Physically-based water movement**

---

## 🧩 Project Structure

```
Assets/
 ├─ Shaders/
 │   └─ GerstnerWave.shader
 ├─ Scripts/
 │   ├─ WaveController.cs      // Sends wave data to shader
 │   └─ BuoyancyWithFlow.cs    // Handles floating physics
 └─ Materials/
     └─ Water.mat
```

---

## 🧠 Physics Concept

- Wave height is computed as:
  ```
  y = Σ (a * sin(k·(d·x - c·t)))
  ```
  where:  
  `a` = amplitude, `k` = wave number, `d` = direction, `c` = wave speed, `t` = time.  

- Buoyancy force:
  ```
  F = (targetHeight - objectHeight) * buoyancyStrength
  ```

- Horizontal motion derives from the wave’s phase derivative.

---

## 🎮 How to Use

1. Assign **GerstnerWave.shader** to a water material.  
2. Attach **WaveController.cs** to the water plane.  
3. Attach **Buoyancy.cs** to floating objects (must have a Rigidbody).  
4. Play the scene — the water animates dynamically, and objects float naturally.

---

## ✨ Future Improvements

- Real-time planar reflections
- Try with Fast-Fourier Transform for wave algorithm 
- Dynamic foam based on per-pixel velocity  
- GPU Compute Shader simulation  
- Caustics integration and subsurface scattering

---

## 👑 Author

Developed by **👑 Tuan Doni** —  
An experiment in real-time water physics and shading for technical research and portfolio showcase.
