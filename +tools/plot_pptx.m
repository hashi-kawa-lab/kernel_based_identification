classdef plot_pptx < handle
    
    properties
        h
        pages
        blankSlide
        myPres
        slide
        width = 960
    end
    
    methods
        function obj = plot_pptx(name)
            if nargin < 1
                name = 'my_template_wide.pptx';
            end
            obj.h = actxserver('PowerPoint.Application');
            obj.myPres=obj.h.Presentations.Open(which(name));
            obj.blankSlide = obj.myPres.SlideMaster.CustomLayouts.Item(2);
            obj.pages = 1;
            obj.add_page();
        end
        
        function add_page(obj, name)
            obj.pages = obj.pages + 1;
            obj.slide = obj.myPres.Slides.AddSlide(obj.pages, obj.blankSlide);
            if nargin > 1
               obj.slide.Shapes.Title.TextFrame.TextRange.Text = name;
            end
        end
        
        function add_plot(obj, f, row, col, row_all, col_all, retry, isequal)
            if nargin < 7 || isempty(retry)
                retry = 0;
            end
            if nargin < 8
                isequal = false;
            end
            if retry > 4
                return
            end
            try
            % width = [0 960], height = [45, 540-35]
            
            width = (obj.width-30*(col_all+1))/col_all;
            height = (460-30*(row_all+1))/row_all;
            
            figure(f), grid on, box on
            try
                set(f.Children, 'FontSize', 10);
                set(f.Children, 'FontName', 'Times New Roman');
            catch
            end
            set(f, 'Position', [100, 100, width, height])
            if isequal
            axis('equal')
            end
            drawnow
            pause(1)
            copygraphics(f, 'ContentType', 'vector', 'BackgroundColor', 'none')
            Image = obj.slide.Shapes.Paste;
            set(Image, 'Left', 30*col+width*(col-1));
            set(Image, 'Top', 45+30*row+height*(row-1));
            set(Image, 'Width', width);
            catch
               obj.add_plot(f, row, col, row_all, col_all, retry+1) 
            end
        end

        function add_plot2(obj, f, row, col, row_all, col_all, retry, isequal)
            if nargin < 7 || isempty(retry)
                retry = 0;
            end
            if nargin < 8
                isequal = false;
            end
            if retry > 4
                return
            end
            try
            % width = [0 960], height = [45, 540-35]
            
            width = (obj.width-30*(col_all+1))/col_all;
            height = (460-30*(row_all+1))/row_all;
            
            figure(f), grid on, box on
            try
                set(f.Children, 'FontSize', 10);
                set(f.Children, 'FontName', 'Times New Roman');
            catch
            end
            set(f, 'Position', [100, 100, width, height])
            if isequal
            axis('equal')
            end
            copygraphics(f, 'ContentType', 'image', 'BackgroundColor', 'none')
            Image = obj.slide.Shapes.Paste;
            set(Image, 'Left', 30*col+width*(col-1));
            set(Image, 'Top', 45+30*row+height*(row-1));
            set(Image, 'Width', width);
            catch
               obj.add_plot(f, row, col, row_all, col_all, retry+1) 
            end
        end
        
        function close(obj)
            Quit(obj.h)
            delete(obj.h)
        end
        
        function saveas(obj, name)
           obj.myPres.SaveAs(name); 
        end
    end
    
end