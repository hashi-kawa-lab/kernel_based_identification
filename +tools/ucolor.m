function code = ucolor(colorname)
    arguments 
        colorname (1,1) string {mustBeMember(colorname, ["red", "green", "blue", "yellow", "purple", "cyan", "brown", "orange", "pink"])}
    end
    switch colorname
        case "red"
            code = [255, 75, 0]/255;
        case "green"
            code = [3, 175, 122]/255;
        case "blue"
            code = [0, 90, 255]/255;
        case "yellow"
            code = [255, 241, 0]/255;
        case "purple"
            code = [153, 0, 153]/255;
        case "cyan"
            code = [77, 196, 255]/255;
        case "brown"
            code = [128, 64, 0]/255;
        case "orange"
            code = [246, 170, 0]/255;
        case "pink"
            code = [255, 128, 130]/255;
    end
end