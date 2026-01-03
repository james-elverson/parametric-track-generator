# parametric-track-generator
Tool to create race-track geometries from user clicks and generate parametric curves for simulation

Overview

This project is an interactive tool for generating parametric race-track centerlines. The user loads a background image (png) of a circuit , clicks points along the desired path, and the program fits a smooth parametric curve through those points. The resulting track (.mat file) can be exported and used in a lap-time simulation tool.

Features

Load track map png background images

Click to define control points along the track

Generate a smooth parametric curve through the points

Use two points with known distance to generate a total track length

Visualize the curve over the track image

Export track coordinates for simulation or further analysis

How it works

User clicks define ordered control points

A spline / interpolation routine generates a smooth curve

Track is represented as functions x(t) and y(t) of a parameter

Intended to interface with a separate lap-time simulator

How to run

clone or download this repository

open the main.m script

run the program and follow on-screen prompts to load image and click points
