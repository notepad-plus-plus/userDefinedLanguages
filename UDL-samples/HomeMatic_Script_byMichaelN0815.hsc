! HomeMatic Script sample for Notepad++ UDL testing

object sysVars = dom.GetObject(ID_SYSTEM_VARIABLES);
string id;

foreach (id, sysVars.EnumIDs()) {
    object sysVar = dom.GetObject(id);
    WriteLine(sysVar.Name() # " = " # sysVar.Value());
}

object programs = dom.GetObject(ID_PROGRAMS);
WriteLine("Programs: " # programs.Count());

real azimuth = system.SunAzimuth();
real altitude = system.SunAltitude();

if (altitude > 0.0) {
    WriteLine("Sun above horizon");
} elseif (altitude == 0.0) {
    WriteLine("Sun at horizon");
} else {
    WriteLine("Sun below horizon");
}

WriteLine("Sunrise: " # system.SunriseTime());
WriteLine("Sunset: " # system.SunsetTime());
