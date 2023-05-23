---
marp: true
math: mathjax
theme: uncover
class: invert
---


# Convolutional Neural Networks

---

## Geometric Deep Learning Blueprint

$$
f = A ◦ σ_J ◦ B_J ◦ P_{J−1} ◦ \dots ◦ P_1 ◦ σ_1 ◦ B_1
$$

---

## Back to Convolutions

$$
\mathbf{C(\theta)}\mathbf{x} = \mathbf{x} \star \mathbf{\theta}
$$

$\mathbf{C}(\mathbf{\theta})$ — circulant matrix with parameters $\mathbf{\theta}$ (weights sharing)

---

## In Discrete Case

Using unit peaks $\mathbf{\theta}_{vw}(u_1, u_2) = δ(u_1 − v, u_2 − w)$ as generators

$$
\mathbf{F(x)} = \sum_{v=1}^{H^f} \sum_{w=1}^{W^f} \alpha_{vw} \mathbf{C}(\mathbf{\theta}_{vw})\mathbf{x}
$$

$\mathbf{x}$ and $\mathbf{\theta}_{vw}$ have their two coordinate dimensions flattened into one — making $\mathbf{x}$ a vector, and $\mathbf{C}(\mathbf{\theta}_{vw})$ a matrix.

---

## By Coordinates

$$
\mathbf{F(x)}_{uv} = \sum_{a=1}^{H^f} \sum_{b=1}^{W^f} \alpha_{ab} x_{u+a,v+b}
$$

---

## Other generators

Directional derivatives:
$$
\mathbf{\theta}_{vw}(u_1, u_2) = δ(u_1, u_2) − δ(u_1 − v, u_2 − w), (v, w) \neq (0, 0)
$$
taken together with the local average
$$
\mathbf{\theta}_{0}(u_1, u_2) = \frac{1}{H_f W_f}
$$

---

## Multiple Channels

$$
\mathbf{F(x)}_{uvj} = \sum_{a=1}^{H^f} \sum_{b=1}^{W^f} \sum_{c=1}^{M} \alpha_{jabc} x_{u+a,v+b,c} \ , \ j \in [N]
$$

---

## Add Non-linearity and Pooling

$$
\mathbf{h} = \mathbf{P}( σ( \mathbf{F(x)} ) )
$$

---

## Skip Connections (Residual Networks)

$$
\mathbf{h} = \mathbf{P}(\mathbf{x} + σ( \mathbf{F(x)} ) )
$$

And don't let me even start on ODEs connection, NeuralODEs, Physics-Informed Neural Networks and other Scientific ML! 😂

---

## Normalization

Replacing layer coefficients $\mathrm{x}_k$ by
$$
\mathrm{\tilde{x}}_k = σ^{−1}_k ⊙ (\mathrm{x}_k − µ_k)
$$
where $µ_k$ and $\sigma_k$ encode the first and second order moment information of $\mathrm{x}_k$, respectively.

---

## Data Augmentation

Not as _data efficient_ as symmetry equi-/invariance but still useful. 😊


---

# Group-Equivariant CNNs

---

## Generalizing to any _Homogeneous Space_ Ω

$$
\forall u, v \in \Omega \ \exists \mathfrak{g} \in \mathfrak{G} \ \mathfrak{g} . u = v
$$

---

## Discrete Group Convolution

- MRI or CT scans

  * $\Omega = \mathbb{Z}^3$
  * $x : \mathbb{Z}^3 \to \mathbb{R}$
  * $\mathfrak{G} = \mathbb{Z}^3 \bowtie O_h$

- DNA sequence

  * $\Omega = \mathbb{Z}$
  * $x : \mathbb{Z} \to \mathbb{R}^4$ one-hot encoding
  * $\mathfrak{G} = \mathbb{Z} \bowtie \mathbb{Z}_2$

---

## The Convolution

$$
(x \star \theta)(\mathfrak{g}) = \sum_{u \in \Omega} x_u \rho(\mathfrak{g}) \theta_u
$$
Recall that $\rho(\mathfrak{g}) \theta_u = \theta_{\mathfrak{g}^{-1}u}$

---

## Transform + Convolve

$$
\mathfrak{g} = \mathfrak{t} \mathfrak{h}
$$
where $\mathfrak{h} \in \mathfrak{H}$ and $\mathfrak{t} \in \mathbb{Z}^d$

---

## In Math

Given $\rho(\mathfrak{g}) = \rho(\mathfrak{t} \mathfrak{h}) = \rho(\mathfrak{t}) \rho(\mathfrak{h})$

$$
(x \star \theta)(\mathfrak{t} \mathfrak{h}) = \sum_{u \in \Omega} x_u \rho(\mathfrak{t}) \rho(\mathfrak{h}) \theta_u = \sum_{u \in \Omega} x_u (\rho(\mathfrak{h}) \theta)_{u - \mathfrak{t}}
$$

---

## In Other Math

$$
(x \star \theta)(\mathfrak{t} \mathfrak{h}) = (x \star \theta_{\mathfrak{h}})(\mathfrak{t})
$$

---

## Spherical CNNs in the Fourier Domain

Convolution on $\mathbb{S}^2$ is a function on $\mathrm{SO}(3)$, hence we need to define the Fourier transform on both these domains in order to implement multi-layer spherical CNNs

- Spherical Harmonics
- Wigner D-functions

