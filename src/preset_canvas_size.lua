-- 默认palette
local A64Palette = {0x000000, 0x1A1C2C, 0x5D275D, 0xB13E53, 0xEF7D57, 0xFFCD75, 0xA7F070, 0x38B764, 0x257179, 0x29366F,
                    0x3B5DC9, 0x41A6F6, 0x73EFF7, 0xFFFFFF, 0xF4F4F4, 0xC2C3C7, 0x8796AE, 0x566C86, 0x333C57, 0x141227,
                    0x442434, 0x663931, 0x8F563B, 0xDF7126, 0xD9A066, 0x8A6F30, 0x6A432D, 0x4E2A4A, 0x852D6C, 0xE03C78,
                    0xFF77A8, 0xFFCCAA, 0xFEB2A1, 0xBC523B, 0x7F253B, 0x4F101C, 0xA1470E, 0xBF7930, 0xC7AD88, 0x6C697B,
                    0x393C48, 0x241C20, 0x432C1B, 0x553C2E, 0x6A4933, 0x996B39, 0xA8885F, 0xC2B59D, 0xD8D7C5, 0xA89B97,
                    0x8C6F6D, 0x6F5656, 0x514749, 0x3B3335, 0x342A25, 0x191316, 0x100B10, 0x2B2338, 0x4D436A, 0x817D93,
                    0xA8A5AC, 0xCCCCCC, 0xE7E7E7, 0xFFFFFF}
local white = Color {
    r = 255,
    g = 255,
    b = 255,
    a = 255
}
local black = Color {
    r = 0,
    g = 0,
    b = 0,
    a = 255
}

-- 插件初始化函数
function init(plugin)
    -- 初始化插件时，加载持久化的用户自定义尺寸
    if plugin.preferences.sizes == nil then
        plugin.preferences.sizes = {} -- 如果没有尺寸数据，则初始化为空表
    end

    -- 上次创建时使用的尺寸
    if plugin.preferences.lastSize == nil then
        plugin.preferences.lastSize = {
            width = 64,
            height = 64
        }
    end
    -- background
    if plugin.preferences.lastBackground == nil then
        plugin.preferences.lastBackground = "Transparent"
    end
    -- 预设画布尺寸
    local defaultPresets = {{
        name = "64x64",
        width = 64,
        height = 64
    }, {
        name = "128x128",
        width = 128,
        height = 128
    }, {
        name = "256x256",
        width = 256,
        height = 256
    }, {
        name = "512x512",
        width = 512,
        height = 512
    }}

    -- 如果插件的尺寸设置为空，则加载默认预设
    if #plugin.preferences.sizes == 0 then
        for _, preset in ipairs(defaultPresets) do
            table.insert(plugin.preferences.sizes, preset)
        end
    end

    -- 创建命令，显示选择画布大小的对话框
    plugin:newCommand{
        id = "PresetCanvasSize",
        title = "Preset Canvas Size",
        group = "file_new", -- 将命令添加到 "File" 菜单下
        onclick = function()
            showCanvasSizeDialog(plugin)
        end
    }
end

-- 插件退出时，保存用户的设置
function exit(plugin)
    print("Exiting plugin, user-defined sizes saved.")
end

-- 显示画布尺寸选择对话框
function showCanvasSizeDialog(plugin)
    local dlg = Dialog("New Sprite")

    -- 默认值
    local defaultWidth = plugin.preferences.lastSize.width
    local defaultHeight = plugin.preferences.lastSize.height
    local defaultColorMode = "RGBA"
    local defaultBackground = "Transparent"

    -- 分割线 Size
    dlg:separator{
        text = "Size"
    }
    -- 添加尺寸输入框
    dlg:entry{
        id = "width",
        label = "Width:",
        text = tostring(defaultWidth),
        focus = true
    }
    dlg:entry{
        id = "height",
        label = "Height:",
        text = tostring(defaultHeight)
    }

    -- 添加自定义尺寸按钮
    dlg:button{
        text = "+ Add Custom Size",
        onclick = function()
            local width = tonumber(dlg.data.width)
            local height = tonumber(dlg.data.height)

            -- 保存自定义尺寸
            local newPresetName = string.format("%dx%d", width, height)
            local newPreset = {
                name = newPresetName,
                width = width,
                height = height
            }

            -- 检查是否已经存在相同尺寸
            for _, preset in ipairs(plugin.preferences.sizes) do
                if preset.name == newPresetName then
                    -- 如果已经存在相同尺寸，则不添加
                    return
                end
            end

            table.insert(plugin.preferences.sizes, newPreset)

            -- 更新下拉框选项
            local updatedOptions = getPresetOptions(plugin)
            dlg:modify{
                id = "preset",
                options = updatedOptions,
                option = newPreset.name -- 选中新增的选项
            }

        end
    }
    -- 预设尺寸下拉框
    dlg:separator{
        text = "Preset"
    }
    -- 预设尺寸下拉框
    -- 添加下拉框
    dlg:combobox{
        id = "preset",
        label = "Size:",
        options = getPresetOptions(plugin),
        option = plugin.preferences.sizes[1].name, -- 默认选中第一个选项
        onchange = function()
            -- 获取当前选项的名称
            local selectedOption = dlg.data.preset

            -- 根据选项名称查找对应的预设
            for _, preset in ipairs(plugin.preferences.sizes) do
                if preset.name == selectedOption then
                    -- 更新输入框的宽度和高度
                    dlg:modify{
                        id = "width",
                        text = tostring(preset.width)
                    }
                    dlg:modify{
                        id = "height",
                        text = tostring(preset.height)
                    }
                    break
                end
            end

        end
    }

    -- 添加颜色模式选项
    dlg:separator{
        text = "Color Mode:"
    }
    local colorModes = {{
        id = "ColorMode_RGBA",
        text = "RGBA",
        selected = (defaultColorMode == "RGBA")
    }, {
        id = "ColorMode_Grayscale",
        text = "Grayscale",
        selected = (defaultColorMode == "Grayscale")
    }, {
        id = "ColorMode_Indexed",
        text = "Indexed",
        selected = (defaultColorMode == "Indexed")
    }}
    for _, mode in ipairs(colorModes) do
        dlg:radio{
            id = mode.id,
            text = mode.text,
            selected = mode.selected,
            onclick = function()
                defaultColorMode = mode.text
                -- 更新颜色模式按钮组状态
                for _, m in ipairs(colorModes) do
                    dlg:modify{
                        id = m.id,
                        selected = (m.text == defaultColorMode)
                    }
                end
            end
        }
    end

    -- 添加背景选项
    dlg:separator{
        text = "Background:"
    }
    --[[   local backgrounds = {{
        id = "Background_Transparent",
        text = "Transparent",
        selected = (defaultBackground == "Transparent")
    }, {
        id = "Background_White",
        text = "White",
        selected = (defaultBackground == "White")
    }, {
        id = "Background_Black",
        text = "Black",
        selected = (defaultBackground == "Black")
    }}
    for _, bg in ipairs(backgrounds) do
        dlg:radio{
            id = "background",
            text = bg.text,
            selected = bg.selected,
            onclick = function()
                defaultBackground = bg.text

                -- 更新背景按钮组状态
                for _, b in ipairs(backgrounds) do
                    dlg:modify{
                        id = background,
                        selected = (b.text == defaultBackground)
                    }
                end
            end
        }
    end ]]
    -- 背景下拉菜单
    dlg:combobox{
        id = "background",
        options = {"Transparent", "White", "Black"},
        option = plugin.preferences.lastBackground,
        onchange = function()
            plugin.preferences.lastBackground = dlg.data.background
            defaultBackground = dlg.data.background

        end
    }

    -- 添加确认和取消按钮
    dlg:separator()
    dlg:button{
        text = "OK",
        onclick = function()
            createNewSprite(dlg, defaultColorMode, plugin)
            -- 保存用户上次使用的尺寸
            plugin.preferences.lastSize.width = tonumber(dlg.data.width)
            plugin.preferences.lastSize.height = tonumber(dlg.data.height)
        end
    }
    dlg:button{
        text = "Cancel"
    }

    -- 显示对话框
    dlg:show{
        wait = false
    }
end

-- 获取预设尺寸选项
function getPresetOptions(plugin)
    local options = {}
    for _, preset in ipairs(plugin.preferences.sizes) do
        table.insert(options, preset.name)
    end
    return options
end

-- 创建新的精灵
function createNewSprite(dlg, colorMode, plugin)

    local width = tonumber(dlg.data.width)
    local height = tonumber(dlg.data.height)
    local background = tostring(dlg.data.background)
    if not width or not height or width <= 0 or height <= 0 then
        app.alert("Width and Height must be positive integers!")
        return
    end

    width = math.floor(width)
    height = math.floor(height)

    local sprite
    if colorMode == "RGBA" then
        sprite = Sprite(width, height, ColorMode.RGB)
    elseif colorMode == "Grayscale" then
        sprite = Sprite(width, height, ColorMode.GRAYSCALE)
    elseif colorMode == "Indexed" then
        sprite = Sprite(width, height, ColorMode.INDEXED)
    else
        app.alert("Invalid color mode selected!")
        return
    end

    -- 创建调色板
    local palette = Palette {
        fromResource = 'AAP-64'
    }

    -- 设置调色板
    sprite:setPalette(palette)

    local fillColor
    if background == "White" then
        fillColor = white
    elseif background == "Black" then
        fillColor = black
    end

    if fillColor then

        -- 设置当前图层为背景图层
        local bgLayer = sprite.layers[1] -- 默认的初始图层
        bgLayer.name = "Background" -- 可选：设置名称

        app.sprite = sprite -- 设置当前精灵

        -- 设置前景色为背景颜色
        app.fgColor = fillColor
        -- 获取背景层的 Cel
        local bgCel = sprite.cels[1]

        -- 获取 Cel 的图像
        local bgImage = bgCel.image

        -- 设置背景色
        local bgColor = fillColor

        -- 清空图像并填充背景色
        bgImage:clear(bgColor)

        -- 新建一个layer
        sprite:newLayer("Layer 1", 1, 1)
        -- 刷新视图
        app.refresh()

    end

    dlg:close()

end
