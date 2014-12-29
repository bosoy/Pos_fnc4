/*
* Pos_fnc4.sqf

* POS_FNC3 = compile preprocessFileLineNumbers "Pos_fnc4.sqf";

* Dimon UA Find position SCRIPT 4.

*

* пример:

    _spawnpoint=[position, [800,1300], 0.1, [0, 100], [10, 10], 0.1, [0,false], [4, 50, 60], [["Static"],20],150] call Pos_fnc3;

 
* _onroad:
  0 - дороги не должно быть
  1 - все равно
  2 - только на дороге
  3 - дороги не должно быть, но в пределах радиус от дороги
  4 - дорога должна быть или допустимый радиус от дороги.
  5 - дороги не должно быть и мин радиус от дороги где не должно быть, + радиус от дороги где можно разместить 
  6 - дороги не должно быть и радиус от дороги где не должно быть
*/

#define cn !(isOnRoad _testPos)
#define ucn (isOnRoad _testPos)
#define tn (count (_testPos nearRoads _xr) == 0)
#define utn (count (_testPos nearRoads _xr) > 0)
#define uctn (count (_testPos nearRoads _xrm) > 0)
#define mn (count (nearestObjects [ _testPos , _neartype, _xdistance]) == 0)
#define sw (surfaceIsWater _testPos)

scopeName "main";

private["_type","_count","_marker","_radius","_minDistance","_minradius","_maxradius","_minGradient","_maxGradient","_gradientRadius","_onShore","_onroad",
        "_xr","_xc","_xrm","_posfind","_neartype","_xdistance","_damage","_typecount","_unittype","_xradius","_xGradient", "_xcountx","_cnt","_isFlat","_poss","_veh"];

_pos = _this select 0;      // центр радиуса размещения обьекта
_minDist = ((_this select 1) select 0);
_maxDist = ((_this select 1) select 1);
_minDistance = _this select 2;     			// минимально допустимая дистанция до ближайшего объекта. 0 - по дефолту
_minradius = ((_this select 3) select 0);  	// минимальный радиус поиска площадки вокруг обьекта
_maxradius = ((_this select 3) select 1); 	// максимальный радиус поиска площадки вокруг обьекта
_minGradient=((_this select 4) select 0);   // минимальное значение максимального допустимого наклона (разница высот) площадки
_maxGradient=((_this select 4) select 1);   // максимальное значение максимального допустимого наклона (разница высот) площадки
_gradientRadius = _this select 5;  			// радиус окружности, в пределах которой учитывается _minGradient
_waterMode=((_this select 6) select 0);
_onShore=((_this select 6) select 1);          			// true если необходима вода в радиусе 25 метров
_onroad=((_this select 7) select 0);  		
_xr=((_this select 7) select 1); 		// 1 радиус в котором ищется наличие дороги.
_xrm=((_this select 7) select 2); 		// 2 радиус в котором ищется наличие дороги.
_neartype=((_this select 8) select 0);      // массив обьектов возле которых при заданной дистанции от обьекта нельзя ставить обьект.
_xdistance=((_this select 8) select 1);     // дистанция до обьектов возле которых нельзя ставить нужный нам обьект(ы).
_xc	= _this select 9; // кол-во проверок позиций
_blacklist = [];
if ((count _this) > 10) then { _blacklist = _this select 10;};
_defaultPos = [];
if ((count _this) > 11) then { _defaultPos = _this select 11;};

if (_waterMode == 2) then { _onroad = 7;};
_debug = false;
//_debug = true; // тестовый вариант
private ["_newPos", "_posX", "_posY"];
_newPos = [];
_posX = _pos select 0;
_posY = _pos select 1;

private ["_xcountx"];

_xradius = (_maxradius - _minradius) / _xc;
_xGradient = (_maxGradient - _minGradient) / _xc;
_xcountx = 0;
for "_xcountx" from 1 to _xc step 1 do 
{
	private ["_newX", "_newY", "_testPos"];
	_newX = _posX + (_maxDist - (random (_maxDist * 2)));
	_newY = _posY + (_maxDist - (random (_maxDist * 2)));
	_testPos = [_newX, _newY];

	if (!([_testPos, _blacklist] call BIS_fnc_isPosBlacklisted) && {(_pos distance _testPos) >= _minDist} && {!((count (_testPos isFlatEmpty [_minDistance, _minradius, _minGradient, _gradientRadius, 0, _onShore, objNull])) == 0)}) then
	{
		call 
		{
			if ((_onroad == 1) && {mn}) exitwith  
			{
				_newPos = _testPos;
				if (_debug) then 
				{
					// Создать маркер возможного размещения
					_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
					_debugMarker = createMarker [str(_newPos), _newPos];
					_debugMarker setMarkerShape "ICON";
					_debugMarker setMarkerType "mil_dot";
					_debugMarker setMarkerColor "ColorRed";
				}; 
				breakTo "main";
			};
			if ( (_onroad == 0) && {cn} && {tn} && {mn}) exitwith  
			{
				_newPos = _testPos;
				if (_debug) then 
				{
					// Создать маркер возможного размещения
					_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
					_debugMarker = createMarker [str(_newPos), _newPos];
					_debugMarker setMarkerShape "ICON";
					_debugMarker setMarkerType "mil_dot";
					_debugMarker setMarkerColor "ColorRed";
				}; 
				breakTo "main";
			};
			if ( (_onroad == 2) && {ucn} && {mn}) exitwith  
			{
				_newPos = _testPos;
				if (_debug) then 
				{
					// Создать маркер возможного размещения
					_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
					_debugMarker = createMarker [str(_newPos), _newPos];
					_debugMarker setMarkerShape "ICON";
					_debugMarker setMarkerType "mil_dot";
					_debugMarker setMarkerColor "ColorRed";
				}; 
				breakTo "main";
			};
			if ( (_onroad == 3) && {cn} && {utn} && {mn}) exitwith  
			{
				_newPos = _testPos;
				if (_debug) then 
				{
					// Создать маркер возможного размещения
					_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
					_debugMarker = createMarker [str(_newPos), _newPos];
					_debugMarker setMarkerShape "ICON";
					_debugMarker setMarkerType "mil_dot";
					_debugMarker setMarkerColor "ColorRed";
				}; 
				breakTo "main";
			};
			if ( (_onroad == 4) && {( ucn || {utn})} && {mn}) exitwith  
			{
				_newPos = _testPos;
				if (_debug) then 
				{
					// Создать маркер возможного размещения
					_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
					_debugMarker = createMarker [str(_newPos), _newPos];
					_debugMarker setMarkerShape "ICON";
					_debugMarker setMarkerType "mil_dot";
					_debugMarker setMarkerColor "ColorRed";
				}; 
				breakTo "main";
			};
			if ( (_onroad == 5) && {cn} && {tn} && {uctn} && {mn}) exitwith  
			{
				_newPos = _testPos;
				if (_debug) then 
				{
					// Создать маркер возможного размещения
					_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
					_debugMarker = createMarker [str(_newPos), _newPos];
					_debugMarker setMarkerShape "ICON";
					_debugMarker setMarkerType "mil_dot";
					_debugMarker setMarkerColor "ColorRed";
				}; 
				breakTo "main";
			};
			if ( (_onroad == 6) && {cn} && {tn} && {mn}) exitwith  
			{
				_newPos = _testPos;
				if (_debug) then 
				{
					// Создать маркер возможного размещения
					_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
					_debugMarker = createMarker [str(_newPos), _newPos];
					_debugMarker setMarkerShape "ICON";
					_debugMarker setMarkerType "mil_dot";
					_debugMarker setMarkerColor "ColorRed";
				}; 
				breakTo "main";
			};
		};
	};
	_minradius = _minradius + _xradius;
	_minGradient = _minGradient + _xGradient;
	if (_debug) then {hintSilent str _xcountx;};
};

if ((count _newPos) == 0) then
{
	if (_waterMode == 0) then
	{
		if ((count _defaultPos) > 0) then 
		{
			_newPos = _defaultPos select 0;
			if (_debug) then 
			{
				// Создать маркер возможного размещения
				_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
				_debugMarker = createMarker [str(_newPos), _newPos];
				_debugMarker setMarkerShape "ICON";
				_debugMarker setMarkerType "mil_dot";
				_debugMarker setMarkerColor "ColorRed";
			}; 
		} 
		else 
		{
			//Use world Armory default position:
			_newPos = getArray(configFile >> "CfgWorlds" >> worldName >> "Armory" >> "positionStart");
			if (_debug) then 
			{
				// Создать маркер возможного размещения
				_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
				_debugMarker = createMarker [str(_newPos), _newPos];
				_debugMarker setMarkerShape "ICON";
				_debugMarker setMarkerType "mil_dot";
				_debugMarker setMarkerColor "ColorRed";
			}; 
		};
	}
	else
	{
		if ((count _defaultPos) > 1) then 
		{
			_newPos = _defaultPos select 1;
			if (_debug) then 
			{
				// Создать маркер возможного размещения
				_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
				_debugMarker = createMarker [str(_newPos), _newPos];
				_debugMarker setMarkerShape "ICON";
				_debugMarker setMarkerType "mil_dot";
				_debugMarker setMarkerColor "ColorRed";
			}; 
		} 
		else 
		{
			//Use world Armory default water position:
			_newPos = getArray(configFile >> "CfgWorlds" >> worldName >> "Armory" >> "positionStartWater");
			if (_debug) then 
			{
				// Создать маркер возможного размещения
				_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
				_debugMarker = createMarker [str(_newPos), _newPos];
				_debugMarker setMarkerShape "ICON";
				_debugMarker setMarkerType "mil_dot";
				_debugMarker setMarkerColor "ColorRed";
			}; 
		};
	};
};

if ((count _newPos) == 0) then 
{
	//Still nothing was found, use world center positions.
	_newPos = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");
	if (_debug) then 
	{
		// Создать маркер возможного размещения
		_dummy = createVehicle ["Sign_sphere25cm_EP1", _newPos, [], 0, "NONE"];
		_debugMarker = createMarker [str(_newPos), _newPos];
		_debugMarker setMarkerShape "ICON";
		_debugMarker setMarkerType "mil_dot";
		_debugMarker setMarkerColor "ColorRed";
	}; 
};

_newPos
