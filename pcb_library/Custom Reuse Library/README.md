# Per-Project Integrated Libraries

Purpose: har Altium project ke used components ko us project ki reusable `.IntLib` me save karna, taki future projects me same schematic symbols, footprints aur 3D models dobara download/search na karne pade.

## Standard workflow

Har project complete hone ke baad:

1. Altium me finished/current project open karo.
2. Schematic ya PCB editor active rakho.
3. Menu: `Design > Make Integrated Library`.
4. Output folder choose karo:
   `D:\pcb_library\Custom Reuse Library\Project IntLibs\<ProjectName>\`
5. Generated `<ProjectName>.IntLib` ko install kar do:
   `Components panel > menu > File-based Libraries Preferences > Installed > Install`
6. Future projects me Components panel se us IntLib ke parts direct place kar sakte ho.

`Make Integrated Library` project ke placed schematic symbols aur PCB footprints se reusable integrated library banata hai. Isme component data portable hota hai, so next time same parts ke liye Celestial/online source dobara hit karna zaroori nahi hota.

## Folder rule

Use this naming:

`Project IntLibs\<ProjectName>\<ProjectName>.IntLib`

Example:

`Project IntLibs\MotorDriverBoard\MotorDriverBoard.IntLib`

## After generation

Agar `.IntLib` Downloads/Desktop ya project output folder me ban gayi ho, helper script run karke usko correct folder me register kar sakte ho:

```powershell
.\Register-ProjectIntLib.ps1 -ProjectName "MotorDriverBoard" -IntLibPath "C:\path\to\MotorDriverBoard.IntLib"
```

Script copied library ko `Project IntLibs\<ProjectName>\` me rakhega aur `Project IntLibs\INDEX.md` update karega.

## Current Celestial setup

Verified Celestial DbLib:

`D:\pcb_library\altium-library\Altium Database Library V2.DbLib`

Local symbol/footprint/model source:

`D:\pcb_library\altium-library\symbols`

`D:\pcb_library\altium-library\footprints`

`D:\pcb_library\altium-library\STEP`
