; Klipper G-code sample for UDL preview
# hash comment (should be green)
#*# ALERT: this line should be dark orange
( block comment: also green )

G28                         ; Home all axes
M104 S200                   ; Set hotend temp
M190 S60                    ; Wait for bed temp

G1 X0 Y0 Z0 F6000           ; Rapid move
G1 X100.25 Y-20.5 E5.0 F1500 ; Coordinated move with extrusion

G92 E0                      ; Reset extruder
G1 E2.5 F300                ; Prime
G1 X120 Y120 Z0.2 F2400     ; Move to start

"string literal for delimiter test"

; Klipper-specific commands
BED_MESH_CALIBRATE
SET_VELOCITY_LIMIT ACCEL=3000
SAVE_CONFIG
