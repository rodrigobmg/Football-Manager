--- ************************************************************************************************************************************************************************
---
---				Name : 		members.lua
---				Purpose :	Classes representing team members and the ball, all the moveable game objects.
---				Updated:	2 November 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--//												Abstract Superclass for all displayable objects
--- ************************************************************************************************************************************************************************

local MoveableGameObject = Framework:createClass("highlights.objects.base")

function MoveableGameObject:constructor(info)
	self.m_distanceToTravel = 0 																-- number of logical units to travel.
	self.m_direction = 90 																		-- current direction.
	self.m_displayObject = self:createGameObject(info)											-- create a game object which implements move(),rotate()
																								-- ** NOT A CORONA DISPLAY OBJECT **
	self:move(info.x,info.y) 																	-- move game object to specified place.
	self:rotate(info.direction) 																-- rotate to direction.
end 		

function MoveableGameObject:destructor()
	self.m_displayObject = nil 																	-- remove reference to display object
end 

function MoveableGameObject:createGameObject(info)												-- this *must* be sub classed.
	error("MoveableGameObject is an abstract class")
end 

function MoveableGameObject:getSpeed()
	return 0.4 
end 

function MoveableGameObject:isRethinkRequired()
	return false 
end 

function MoveableGameObject:rethink() 
end 

function MoveableGameObject:moveTo(x,y)
	x = x or self.m_xLogical y = y or self.m_yLogical 											-- default options
	if x == self.m_xLogical and y == self.m_yLogical then return end 							-- already at that point, do nothing.
	local dir = math.atan2(y - self.m_yLogical,x - self.m_xLogical)								-- work out direction to go
	dir = math.deg(dir) 																		-- convert to degrees
	local distance = math.sqrt((x-self.m_xLogical)*(x-self.m_xLogical)+ 						-- work out distance to move.
															(y-self.m_yLogical)*(y-self.m_yLogical))	
	self:rotate(dir)																			-- set the graphic rotation.
	self.m_distanceToTravel = distance self.m_direction = math.rad(dir) 						-- set the travelling distance and direction.
end																		

function MoveableGameObject:tick(deltaTime)
	if self.m_distanceToTravel <= 0 or self:isRethinkRequired() then 							-- reached end, or is a rethink required
		self:rethink() 																			-- decide what to do next.
		if self:isRethinkRequired() then self.m_distanceToTravel = 0 end 						-- if rethink required zero travel distance
	end 
	if self.m_distanceToTravel <= 0 then return end 											-- doing nothing.
	local dist = math.min(deltaTime * self:getSpeed() * 1000,self.m_distanceToTravel)			-- how far to go.
	self.m_distanceToTravel = self.m_distanceToTravel - dist 									-- reduce distance to go.
	self:move(self.m_xLogical+dist*math.cos(self.m_direction),
			  self.m_yLogical+dist*math.sin(self.m_direction))						 
end 

function MoveableGameObject:move(x,y)
	self.m_xLogical,self.m_yLogical = x,y 														-- save logical position
	x = ((x or 0)*0.9 + 512) / 1024 * display.contentWidth  									-- calculate actual physical position
	y = (y or 0)*0.57 + 40 															
	self.m_displayObject:move(x,y)																-- and draw it
end 

function MoveableGameObject:rotate(angle)
	self.m_direction = angle or self.m_direction 												-- default is original value
	self.m_displayObject:setRotation(self.m_direction)											-- update direction.
end 

--- ************************************************************************************************************************************************************************
--															Base Player Class
--- ************************************************************************************************************************************************************************

local Player,SuperClass = Framework:createClass("highlights.objects.player","highlights.objects.base")

function Player:createGameObject(info)
	local displayObj = Framework:new("gfx.player",{ camera = info.camera }) 					-- create a player display object
	displayObj:setRadius(32)																	-- set its size
	return displayObj 																			-- and return it.
end 

local Goalkeeper,SuperClass = Framework:createClass("highlights.objects.goalkeeper","highlights.objects.player")

local Attacker,SuperClass = Framework:createClass("highlights.objects.attacker","highlights.objects.player")

local CentreForward,SuperClass = Framework:createClass("highlights.objects.centreforward","highlights.objects.attacker")

local Defender,SuperClass = Framework:createClass("highlights.objects.defender","highlights.objects.player")

local Ball,SuperClass = Framework:createClass("highlights.objects.ball","highlights.objects.base")

--[[

	shirt/shorts/skin code on initialisation.
	abstract out logical->physical
	then start building up highlights object.

--]]

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		2-Nov-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
