local capabilities = require "st.capabilities"
local ZigbeeDriver = require "st.zigbee"
local clusters = require "st.zigbee.zcl.clusters"
local device_management = require "st.zigbee.device_management"

local FanControl = clusters.FanControl
local OnOff = clusters.OnOff
local Level = clusters.Level


------------------------------------------------------------
-- ZIGBEE ATTRIBUTE HANDLERS
------------------------------------------------------------

local function fan_mode_handler(driver, device, value, zb_rx)
  local raw_mode = value.value

  device.log.info(string.format(
    "Received FanMode: %s",
    tostring(raw_mode)
  ))

  -- KOF:
  -- 0 = Off
  -- 1 = Low
  -- 2 = Medium
  -- 3 = High
  -- 4 = Max
  -- 6 = Breeze
  --
  -- SmartThings uses 5 for Breeze.
  local smartthings_speed = raw_mode

  if raw_mode == 6 then
    smartthings_speed = 5
  end

  if smartthings_speed >= 0 and smartthings_speed <= 5 then
    device:emit_event(
      capabilities.fanSpeed.fanSpeed(smartthings_speed)
    )
  end

  -- Remember last actual running speed so ON can restore it.
  if smartthings_speed > 0 then
    device:set_field(
      "LAST_FAN_SPEED",
      smartthings_speed,
      { persist = true }
    )
  end

  local switch_state =
    raw_mode > 0 and capabilities.switch.switch.on()
                 or capabilities.switch.switch.off()

  device:emit_component_event(
    device.profile.components.main,
    switch_state
  )
end


local function light_onoff_handler(driver, device, value, zb_rx)
  device.log.info(string.format(
    "Received Light OnOff: %s",
    tostring(value.value)
  ))

  local event =
    value.value and capabilities.switch.switch.on()
                or capabilities.switch.switch.off()

  device:emit_component_event(
    device.profile.components.light,
    event
  )
end


local function light_level_handler(driver, device, value, zb_rx)
  local percent =
    math.floor((value.value / 254.0 * 100) + 0.5)

  device.log.info(string.format(
    "Received Light Level: raw=%s percent=%s",
    tostring(value.value),
    tostring(percent)
  ))

  device:emit_component_event(
    device.profile.components.light,
    capabilities.switchLevel.level(percent)
  )
end

------------------------------------------------------------
-- FAN COMMAND READBACK
------------------------------------------------------------

local function schedule_fan_readback(device)

  device.thread:call_with_delay(
    0.5,
    function()
      device.log.info("Reading FanMode after command")

      device:send(
        FanControl.attributes.FanMode:read(device)
      )
    end
  )

end

------------------------------------------------------------
-- LIGHT COMMAND READBACK
------------------------------------------------------------

local function schedule_light_readback(device)

  device.thread:call_with_delay(
    0.5,
    function()
      device.log.info("Reading Light state after command")

      device:send(
        OnOff.attributes.OnOff:read(device)
      )

      device:send(
        Level.attributes.CurrentLevel:read(device)
      )
    end
  )

end

------------------------------------------------------------
-- SWITCH ON / OFF
------------------------------------------------------------

local function switch_on_handler(driver, device, command)

  if command.component == "light" then

    device.log.info("Sending Light ON")
    device:send(
      OnOff.server.commands.On(device)
    )

    else

    local last_speed = device:get_field("LAST_FAN_SPEED")
    local speed = tonumber(last_speed) or 1

    local zigbee_speed = speed

    if zigbee_speed == 5 then
      zigbee_speed = 6
    end

    device.log.info(string.format(
      "Sending Fan ON: speed=%s zigbee=%s",
      tostring(speed),
      tostring(zigbee_speed)
    ))

    device:send(
      FanControl.attributes.FanMode:write(
        device,
        zigbee_speed
      )
    )

    -- Immediate UI feedback
    device:emit_component_event(
      device.profile.components.main,
      capabilities.switch.switch.on()
    )

    device:emit_event(
      capabilities.fanSpeed.fanSpeed(speed)
    )

    -- Confirm actual controller state shortly afterward
    schedule_fan_readback(device)

  end
end


local function switch_off_handler(driver, device, command)

  if command.component == "light" then

    device.log.info("Sending Light OFF")
    device:send(
      OnOff.server.commands.Off(device)
    )

   else

    device.log.info("Sending Fan OFF")

    device:send(
      FanControl.attributes.FanMode:write(
        device,
        0
      )
    )

    -- Immediate UI feedback
    device:emit_component_event(
      device.profile.components.main,
      capabilities.switch.switch.off()
    )

    device:emit_event(
      capabilities.fanSpeed.fanSpeed(0)
    )

    -- Confirm actual controller state shortly afterward
    schedule_fan_readback(device)

  end
end


------------------------------------------------------------
-- LIGHT DIMMING
------------------------------------------------------------

local function set_level_handler(driver, device, command)

  if command.component ~= "light" then
    device.log.info(
      "Ignoring setLevel for non-light component"
    )
    return
  end

  local percent = tonumber(command.args.level) or 0

  if percent < 0 then percent = 0 end
  if percent > 100 then percent = 100 end

  local zigbee_level =
    math.floor((percent / 100.0 * 254) + 0.5)

  device.log.info(string.format(
    "Sending Light Level: percent=%s zigbee=%s",
    tostring(percent),
    tostring(zigbee_level)
  ))

  device:send(
    Level.server.commands.MoveToLevelWithOnOff(
      device,
      zigbee_level,
      0
    )
  )

  -- Immediate SmartThings UI feedback
  device:emit_component_event(
    device.profile.components.light,
    capabilities.switchLevel.level(percent)
  )

  local switch_state =
    percent > 0 and capabilities.switch.switch.on()
                or capabilities.switch.switch.off()

  device:emit_component_event(
    device.profile.components.light,
    switch_state
  )

  -- Confirm actual controller state shortly afterward
  schedule_light_readback(device)

end

------------------------------------------------------------
-- FAN SPEED
------------------------------------------------------------

local function set_fan_speed_handler(driver, device, command)

  local speed = tonumber(command.args.speed)

  if speed == nil then
    device.log.warn("Fan speed command contained no speed")
    return
  end

  if speed < 0 then speed = 0 end
  if speed > 5 then speed = 5 end

  local zigbee_speed = speed

  -- SmartThings 5 = KOF Breeze mode 6
  if zigbee_speed == 5 then
    zigbee_speed = 6
  end

  device.log.info(string.format(
    "Sending Fan Speed: speed=%s zigbee=%s",
    tostring(speed),
    tostring(zigbee_speed)
  ))

  device:send(
    FanControl.attributes.FanMode:write(
      device,
      zigbee_speed
    )
  )

  -- Immediate SmartThings UI feedback
  device:emit_event(
    capabilities.fanSpeed.fanSpeed(speed)
  )

  local switch_state =
    speed > 0 and capabilities.switch.switch.on()
              or capabilities.switch.switch.off()

  device:emit_component_event(
    device.profile.components.main,
    switch_state
  )

  -- Remember requested running speed
  if speed > 0 then
    device:set_field(
      "LAST_FAN_SPEED",
      speed,
      { persist = true }
    )
  end

  -- Confirm actual controller state
  schedule_fan_readback(device)

end


------------------------------------------------------------
-- MANUAL REFRESH
------------------------------------------------------------

local function refresh_handler(driver, device, command)

  device.log.info(string.format(
    "Manual refresh requested: component=%s",
    tostring(command.component)
  ))

  if command.component == "light" then

    device:send(
      OnOff.attributes.OnOff:read(device)
    )

    device:send(
      Level.attributes.CurrentLevel:read(device)
    )

  else

    device:send(
      FanControl.attributes.FanMode:read(device)
    )

  end
end

------------------------------------------------------------
-- LIGHT ON/OFF REPORTING
------------------------------------------------------------

local function configure_reporting(driver, device)

  device.log.info("Configuring Light OnOff and FanMode reporting")

  -- Light On/Off
  device:send(
    device_management.build_bind_request(
      device,
      OnOff.ID,
      driver.environment_info.hub_zigbee_eui
    )
  )

  device:send(
    OnOff.attributes.OnOff:configure_reporting(
      device,
      0,
      21600
    )
  )

  -- Light Level
  device:send(
    device_management.build_bind_request(
      device,
      Level.ID,
      driver.environment_info.hub_zigbee_eui
    )
  )

  device:send(
    Level.attributes.CurrentLevel:configure_reporting(
      device,
      1,
      600,
      1
    )
  )

  -- Fan Mode
  device:send(
    device_management.build_bind_request(
      device,
      FanControl.ID,
      driver.environment_info.hub_zigbee_eui
    )
  )

  device:send(
    FanControl.attributes.FanMode:configure_reporting(
      device,
        1,
  	600
    )
  )

end

------------------------------------------------------------
-- DRIVER
------------------------------------------------------------

local driver_template = {

  supported_capabilities = {
    capabilities.switch,
    capabilities.switchLevel,
    capabilities.fanSpeed,
    capabilities.refresh
  },

  capability_handlers = {

    [capabilities.switch.ID] = {
      [capabilities.switch.commands.on.NAME] =
        switch_on_handler,

      [capabilities.switch.commands.off.NAME] =
        switch_off_handler
    },

    [capabilities.switchLevel.ID] = {
      [capabilities.switchLevel.commands.setLevel.NAME] =
        set_level_handler
    },

    [capabilities.fanSpeed.ID] = {
      [capabilities.fanSpeed.commands.setFanSpeed.NAME] =
        set_fan_speed_handler
    },

    [capabilities.refresh.ID] = {
      [capabilities.refresh.commands.refresh.NAME] =
        refresh_handler
    }

  },

  zigbee_handlers = {
    attr = {

      [FanControl.ID] = {
        [FanControl.attributes.FanMode.ID] =
          fan_mode_handler
      },

      [OnOff.ID] = {
        [OnOff.attributes.OnOff.ID] =
          light_onoff_handler
      },

      [Level.ID] = {
        [Level.attributes.CurrentLevel.ID] =
          light_level_handler
      }

    }
  },

lifecycle_handlers = {
  doConfigure = configure_reporting
},

  health_check = false
}


local driver =
  ZigbeeDriver("cgpt-hampton-bay-fan", driver_template)

driver:run()