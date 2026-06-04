#!/usr/bin/env node
// Run: node generate-icons.js
// Requires: npm install canvas (or use a service like realfavicongenerator.net)
// This script creates placeholder PNG icons for PWA

const { createCanvas } = require('canvas')
const fs = require('fs')
const path = require('path')

const sizes = [72, 96, 128, 144, 152, 192, 384, 512]
const outputDir = path.join(__dirname, 'public', 'icons')

if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true })

sizes.forEach(size => {
  const canvas = createCanvas(size, size)
  const ctx = canvas.getContext('2d')

  // Background
  const gradient = ctx.createLinearGradient(0, 0, size, size)
  gradient.addColorStop(0, '#FF6B35')
  gradient.addColorStop(1, '#FF8C42')
  ctx.fillStyle = gradient

  // Rounded rect
  const r = size * 0.22
  ctx.beginPath()
  ctx.moveTo(r, 0)
  ctx.lineTo(size - r, 0)
  ctx.quadraticCurveTo(size, 0, size, r)
  ctx.lineTo(size, size - r)
  ctx.quadraticCurveTo(size, size, size - r, size)
  ctx.lineTo(r, size)
  ctx.quadraticCurveTo(0, size, 0, size - r)
  ctx.lineTo(0, r)
  ctx.quadraticCurveTo(0, 0, r, 0)
  ctx.closePath()
  ctx.fill()

  // Letter R
  ctx.fillStyle = '#ffffff'
  ctx.font = `800 ${size * 0.55}px system-ui`
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText('R', size / 2, size / 2 + size * 0.03)

  const buffer = canvas.toBuffer('image/png')
  fs.writeFileSync(path.join(outputDir, `icon-${size}x${size}.png`), buffer)
  console.log(`Generated icon-${size}x${size}.png`)
})
