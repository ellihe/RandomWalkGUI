classdef RandomWalkProject_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        IterationTimesEditField     matlab.ui.control.NumericEditField
        IterationTimesLabel         matlab.ui.control.Label
        CurrentCoordinatesLabel     matlab.ui.control.Label
        TabGroup                    matlab.ui.container.TabGroup
        MarkerTab                   matlab.ui.container.Tab
        ColorButton                 matlab.ui.control.Button
        SizeSpinner                 matlab.ui.control.Spinner
        SizeSpinnerLabel            matlab.ui.control.Label
        MarkerDropDown              matlab.ui.control.DropDown
        MarkerDropDownLabel         matlab.ui.control.Label
        FunctionalityTab            matlab.ui.container.Tab
        AxisLimitsSlider            matlab.ui.control.Slider
        AxisLimitsLabel             matlab.ui.control.Label
        DeltaKnob                   matlab.ui.control.Knob
        DeltaKnobLabel              matlab.ui.control.Label
        StepEditField               matlab.ui.control.NumericEditField
        StepEditFieldLabel          matlab.ui.control.Label
        TrailTab                    matlab.ui.container.Tab
        TrailWidthSpinner           matlab.ui.control.Spinner
        LineWidthSpinnerLabel       matlab.ui.control.Label
        TrailColorButton            matlab.ui.control.Button
        TrailStyleDropDown          matlab.ui.control.DropDown
        LineStyleDropDownLabel      matlab.ui.control.Label
        TrailSwitch                 matlab.ui.control.Switch
        ProbabilityDistributionTab  matlab.ui.container.Tab
        DiscreteValuesKnob          matlab.ui.control.DiscreteKnob
        NumberofDiscreteValuesKnobLabel  matlab.ui.control.Label
        DistributionTypeSwitch      matlab.ui.control.RockerSwitch
        yEditField                  matlab.ui.control.NumericEditField
        yEditFieldLabel             matlab.ui.control.Label
        xEditField                  matlab.ui.control.NumericEditField
        xEditFieldLabel             matlab.ui.control.Label
        StartButton                 matlab.ui.control.Button
        UIAxes                      matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        Hplot               % Kahva plottiin
        Hanimation          % Kahva animaatioon
        Running = false     % Kertoo animaation tilan, true jos käynnissä
        FaceClr = 'red'     % Markerin väri
        EdgeClr = 'black'   % Markerin reunan väri
        Delta = 0.5         % Paljonko akseleita siirretään
        Step = 0.1          % Kuinka paljon kuvaaja siirtyy
        LineColor = 'black' % Jäljen väri
        d                   % dialogi
        isDiscrete = false  % Todennäköisyysjakauman tyyppi, onko jatkuva vai diskreetti
        DiscreteValuesN = 2 % Diskreetin jakauman mahdollisten arvojen määrä
    end
    
    methods (Access = private)
        
        % Funktio, joka tulostaa virheilmoituksen kutsuttaessa
        % parametrit: errorText, tulostettava virheilmoitus
        function printErrorDialog(app, errorText)
            app.d = dialog('Position',[300 300 250 150],'Name','Error Message');

                    uicontrol('Parent',app.d,...
                   'Style','text',...
                   'Position',[20 80 210 40],...
                   'String', errorText);
    
                   uicontrol('Parent',app.d,...
                   'Position',[85 20 70 25],...
                   'String','Close',...
                   'Callback','delete(gcf)');
        end
        
        % Funktio laskee ja palauttaa satunnaisluvun theta. 
        % Jos isDiscrete on true, halutaan tasajakautunut diskreetti jakauma, 
        % jolla on arvot 0, 2pi/n, 2pi*2/n, ... , 2pi*(n-1)/n, missä n on kokonaislukuproperty.
        % Jos isDiscrete on false, lasketaan kulma jatkuvasta välillä [0, 2pi)
        % tasajakautuneesta jakaumasta
        function theta = countRandomAngle(app)
        
            if app.isDiscrete
                % Nyt lasketaan vain satunnaiskokonaisluku k väliltä [0, n], ja siitä theta
                n = app.DiscreteValuesN;
                k = randi([0, n-1]);
                theta = 2*pi*k/n;
            else
                theta = 2*pi*rand();    % Nyt palautetaan vain randomluku väliltä [0, 2pi)
            end
            
        end 
        
        function createPlot(app)
            prev_x = 0;
            prev_y = 0;
            app.Hplot = plot(app.UIAxes, prev_x, prev_y,...
                        'Marker', app.MarkerDropDown.Value, 'MarkerSize', app.SizeSpinner.Value,...
                        'MarkerEdgeColor', app.EdgeClr, 'MarkerFaceColor', app.FaceClr);
        end
        
        function createAnimation(app)
            prev_x = 0;
            prev_y = 0;
            app.Hanimation = animatedline(app.UIAxes, prev_x, prev_y,...
                        'Marker', app.MarkerDropDown.Value, 'MarkerSize',...
                        app.SizeSpinner.Value, 'MarkerEdgeColor', app.EdgeClr,...
                        'MarkerFaceColor', app.FaceClr,'MaximumNumPoints', Inf,...
                        'LineStyle', app.TrailStyleDropDown.Value, 'LineWidth',...
                        app.TrailWidthSpinner.Value, 'Color', app.LineColor);
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.TrailSwitch.UserData = false;
            app.MarkerDropDown.Items = {'Point', 'Circle', 'Plus', 'Asterisk',...
                'Cross', 'Square', 'Diamond', 'Upward-pointing triangle',...
                'Downward-pointing triangle', 'Right-pointing triangle',...
                'Left-pointing triangle', 'Five-pointed star (pentagram)',...
                'Six-pointed star (hexagram)', 'No markers'};
            app.MarkerDropDown.ItemsData = {'.', 'o', '+', '*', 'x', 's', 'd',...
                '^', 'v', '>', '<', 'p', 'h', 'none'};
            app.TrailStyleDropDown.Items = {'Solid', 'Dashed',...
                'Dotted', 'Dashed-dotted', 'No line'};
            app.TrailStyleDropDown.ItemsData = {'-', '--', ':', '-.', 'none'};
            app.MarkerDropDown.Value = 'o';
            
            app.UIAxes.XLim(1) = -0.5; app.UIAxes.XLim(2) = 0.5;
            app.UIAxes.YLim(1) = -0.5; app.UIAxes.YLim(2) = 0.5;
            app.DeltaKnob.MajorTicks = 0:1:10;
            app.DeltaKnob.MinorTicks = 0:0.5:10;
            
            app.DiscreteValuesKnob.Items = {'1', '2', '3', '4', '5', '6', '7', '8', ...
                '9',' 10', '11', '12', '13', '14', '15', '16'};
            app.DiscreteValuesKnob.ItemsData = 1:16;
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
          
            if app.Running
                % Jos ajo on päällä, pysäytetään se napin painamisen
                % seurauksena
                app.Running = false;
                app.StartButton.Text = 'Start';
                app.StartButton.BackgroundColor = 'green';
            else
                % Jos ajo pois päältä, käynnistetään se
                app.Running = true;
                app.StartButton.Text = 'Stop';
                app.StartButton.BackgroundColor = 'red';
                
                cla(app.UIAxes) % Tyhjentää akselit
                app.IterationTimesEditField.Value = 0;  % Alustetaan laskuri
                
                % Aiempien koordinaattien alustus
                prev_x = 0;
                prev_y = 0;
                
                % Asettaa akseleiden rajat
                app.UIAxes.XLim(1) = -app.AxisLimitsSlider.Value;
                app.UIAxes.XLim(2) = app.AxisLimitsSlider.Value;
                app.UIAxes.YLim(1) = -app.AxisLimitsSlider.Value;
                app.UIAxes.YLim(2) = app.AxisLimitsSlider.Value;
  
                % Tehdään kuvaajasta animaatiosarja, jos käyttäjä haluaa,
                % muussa tapauksessa normaali kuvaaja plotilla
                if app.TrailSwitch.UserData
                    createAnimation(app);
                else
                    createPlot(app);
                end
                
                while app.Running
                    theta = countRandomAngle(app);  % Todnäkjakauman mukainen randomkulma
                    x = prev_x + app.Step*cos(theta);
                    y = prev_y + app.Step*sin(theta);
                    
                    % Jos kuvaaja tehty plotilla, muokataan x: ja y:n
                    % arvoja, muussa tapauksessa lisätään pisteet
                    % animaatioon
                    if ~app.TrailSwitch.UserData
                        app.Hplot.XData = x;
                        app.Hplot.YData = y;
                    else
                        app.TrailSwitch.UserData
                        addpoints(app.Hanimation, x,y)
                    end
                    
                    app.xEditField.Value = x;
                    app.yEditField.Value = y;
                    
                    % Muuttaa akseleiden rajoja tarvittaessa
                    if x < app.UIAxes.XLim(1)
                        app.UIAxes.XLim(1) = x - app.Delta;
                    elseif x > app.UIAxes.XLim(2)
                        app.UIAxes.XLim(2) = x + app.Delta;
                    elseif y < app.UIAxes.YLim(1)
                        app.UIAxes.YLim(1) = y - app.Delta;
                    elseif y > app.UIAxes.YLim(2)
                        app.UIAxes.YLim(2) = y + app.Delta;
                    end
                    
                    prev_x = x;
                    prev_y = y;
                    drawnow
                    % Laskurin päivitys
                    app.IterationTimesEditField.Value = app.IterationTimesEditField.Value + 1;
                end           
            end
        end

        % Value changed function: MarkerDropDown
        function MarkerDropDownValueChanged(app, event)
            value = app.MarkerDropDown.Value;
            % Virhe, jos yritetään laittaa marker tyhjäksi linen ollessa tyhjä 
            if strcmp(app.MarkerDropDown.Value, 'none') && strcmp(app.TrailStyleDropDown.Value,'none')
                printErrorDialog(app, "Error: Marker and Line Style can't both be 'none'");
                app.MarkerDropDown.Value = 'o';
            else
                % Virhe, jos linea ei näytetä ja marker yritetään asettaa
                % tyhjäksi
                if strcmp(app.MarkerDropDown.Value, 'none') && app.TrailSwitch.UserData == false
                    printErrorDialog(app, "Error: Marker can't be 'none' if trail is off");
                    app.MarkerDropDown.Value = 'o';
                else
                    if ~app.TrailSwitch.UserData
                        set(app.Hplot,'Marker', value);
                    else
                        set(app.Hanimation, 'Marker', value)
                    end
                end
            end
        end

        % Value changed function: SizeSpinner
        function SizeSpinnerValueChanged(app, event)
            value = app.SizeSpinner.Value;
            if ~app.TrailSwitch.UserData
                 set(app.Hplot, 'MarkerSize',value);
            else
                set(app.Hanimation, 'MarkerSize', value);
            end
           
        end

        % Value changed function: DeltaKnob
        function DeltaKnobValueChanged(app, event)
            value = app.DeltaKnob.Value;
            app.Delta = value;
        end

        % Value changed function: StepEditField
        function StepEditFieldValueChanged(app, event)
            value = app.StepEditField.Value;
            app.Step = value;
        end

        % Value changed function: TrailSwitch
        function TrailSwitchValueChanged(app, event)
            if app.Running
               printErrorDialog(app, "Error: cannot switch when running.");
               % Muutetaan arvo, siihen mikä se oli ennen napin
               % painallusta
               if app.TrailSwitch.Value == "No trail"
                   app.TrailSwitch.Value = "Trail";
               else
                   app.TrailSwitch.Value = "No trail";
               end
            else
                if ~app.TrailSwitch.UserData
                    app.TrailSwitch.UserData = true;
                    createAnimation(app);
                else
                    if strcmp(app.MarkerDropDown.Value, 'none')
                        printErrorDialog(app, "Error: cannot switch trail off if marker is 'none'")
                        app.TrailSwitch.Value = "Trail";
                    else
                        app.TrailSwitch.UserData = false;
                        createPlot(app);
                    end
                end
            end
        end

        % Value changed function: TrailStyleDropDown
        function TrailStyleDropDownValueChanged(app, event)
            value = app.TrailStyleDropDown.Value;
            % Virhe, jos line yritetään asettaa tyhjäksi markerin ollessa
            % tyhjä
            if strcmp(app.MarkerDropDown.Value, 'none') && strcmp(app.TrailStyleDropDown.Value,'none')
               printErrorDialog(app, "Error: Marker and LineStyle can't be both 'none'");
               app.TrailStyleDropDown.Value = '-';
            else
                if app.TrailSwitch.UserData
                     set(app.Hanimation,'LineStyle', value);
                end 
            end
        end

        % Value changed function: TrailWidthSpinner
        function TrailWidthSpinnerValueChanged(app, event)
            value = app.TrailWidthSpinner.Value;
            if app.TrailSwitch.UserData
                set(app.Hanimation, 'LineWidth', value);
            end
        end

        % Button pushed function: TrailColorButton
        function TrailColorButtonPushed(app, event)
            % Muuttaa linen väriä
            app.LineColor = uisetcolor([1 0 0], 'Set Line Color');
            if app.TrailSwitch.UserData
                set(app.Hanimation, 'Color', app.LineColor);
            end 
            % Muuttaa buttonin väriä
            app.TrailColorButton.BackgroundColor = app.LineColor;
            if isequal(app.LineColor, [0 0 0])
                app.TrailColorButton.FontColor = 'white';
            else
                app.TrailColorButton.FontColor = 'k';
            end
        end

        % Button pushed function: ColorButton
        function ColorButtonPushed(app, event)
            % Vaihdetaan markerin värit käyttäjän syötteestä
            app.FaceClr = uisetcolor([1 0 0], 'Set Marker Face Color');
            app.EdgeClr = uisetcolor([1 1 1], 'Set Marker Edge Color');
            if ~app.TrailSwitch.UserData
                app.Hplot.MarkerFaceColor = app.FaceClr;
                app.Hplot.MarkerEdgeColor = app.EdgeClr;
            else
                set(app.Hanimation, 'MarkerFaceColor', app.FaceClr)
                set(app.Hanimation, 'MarkerEdgeColor', app.EdgeClr)
            end
            
            % Muuttaa buttonin värin
            app.ColorButton.BackgroundColor = app.FaceClr;
            if isequal(app.FaceClr, [0 0 0])
                app.ColorButton.FontColor = 'white';
            else
                app.ColorButton.FontColor = 'k';
            end            
        end

        % Value changed function: DiscreteValuesKnob
        function DiscreteValuesKnobValueChanged(app, event)
            % Tallennus propertyyn
            app.DiscreteValuesN = app.DiscreteValuesKnob.Value;
        end

        % Value changed function: DistributionTypeSwitch
        function DistributionTypeSwitchValueChanged(app, event)
             % Jos on käynnissä ei voi muuttaa
            if app.Running
                printErrorDialog(app, "Error. Can't change the distribution type when running.")
                % Muutetaan takaisin
                if app.DistributionTypeSwitch.Value == "Continuous"
                    app.DistributionTypeSwitch.Value = "Discrete";
                else
                    app.DistributionTypeSwitch.Value = "Continuous";
                end
            else
                % Vaihdetaan propertyjen arvot
                if app.isDiscrete
                    app.isDiscrete = false;
                else
                    app.isDiscrete = true;
                end
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Random Walk')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.PlotBoxAspectRatio = [1.42628205128205 1 1];
            app.UIAxes.XTickLabelRotation = 0;
            app.UIAxes.YTickLabelRotation = 0;
            app.UIAxes.ZTickLabelRotation = 0;
            app.UIAxes.Position = [23 147 404 305];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0 1 0];
            app.StartButton.Position = [485 401 100 22];
            app.StartButton.Text = 'Start';

            % Create xEditFieldLabel
            app.xEditFieldLabel = uilabel(app.UIFigure);
            app.xEditFieldLabel.HorizontalAlignment = 'right';
            app.xEditFieldLabel.Position = [46 81 25 22];
            app.xEditFieldLabel.Text = 'x';

            % Create xEditField
            app.xEditField = uieditfield(app.UIFigure, 'numeric');
            app.xEditField.Editable = 'off';
            app.xEditField.Position = [86 81 100 22];

            % Create yEditFieldLabel
            app.yEditFieldLabel = uilabel(app.UIFigure);
            app.yEditFieldLabel.HorizontalAlignment = 'right';
            app.yEditFieldLabel.Position = [49 43 25 22];
            app.yEditFieldLabel.Text = 'y';

            % Create yEditField
            app.yEditField = uieditfield(app.UIFigure, 'numeric');
            app.yEditField.Editable = 'off';
            app.yEditField.Position = [86 43 100 22];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [437 42 191 338];

            % Create MarkerTab
            app.MarkerTab = uitab(app.TabGroup);
            app.MarkerTab.Title = 'Marker';

            % Create MarkerDropDownLabel
            app.MarkerDropDownLabel = uilabel(app.MarkerTab);
            app.MarkerDropDownLabel.HorizontalAlignment = 'right';
            app.MarkerDropDownLabel.Position = [17 256 43 22];
            app.MarkerDropDownLabel.Text = 'Marker';

            % Create MarkerDropDown
            app.MarkerDropDown = uidropdown(app.MarkerTab);
            app.MarkerDropDown.ValueChangedFcn = createCallbackFcn(app, @MarkerDropDownValueChanged, true);
            app.MarkerDropDown.Position = [75 256 100 22];

            % Create SizeSpinnerLabel
            app.SizeSpinnerLabel = uilabel(app.MarkerTab);
            app.SizeSpinnerLabel.HorizontalAlignment = 'right';
            app.SizeSpinnerLabel.Position = [44 188 29 22];
            app.SizeSpinnerLabel.Text = 'Size';

            % Create SizeSpinner
            app.SizeSpinner = uispinner(app.MarkerTab);
            app.SizeSpinner.Limits = [1 Inf];
            app.SizeSpinner.ValueChangedFcn = createCallbackFcn(app, @SizeSpinnerValueChanged, true);
            app.SizeSpinner.Position = [88 188 59 22];
            app.SizeSpinner.Value = 5;

            % Create ColorButton
            app.ColorButton = uibutton(app.MarkerTab, 'push');
            app.ColorButton.ButtonPushedFcn = createCallbackFcn(app, @ColorButtonPushed, true);
            app.ColorButton.Position = [48 105 100 22];
            app.ColorButton.Text = 'Color';

            % Create FunctionalityTab
            app.FunctionalityTab = uitab(app.TabGroup);
            app.FunctionalityTab.Title = 'Functionality';

            % Create StepEditFieldLabel
            app.StepEditFieldLabel = uilabel(app.FunctionalityTab);
            app.StepEditFieldLabel.HorizontalAlignment = 'right';
            app.StepEditFieldLabel.Position = [43 265 30 22];
            app.StepEditFieldLabel.Text = 'Step';

            % Create StepEditField
            app.StepEditField = uieditfield(app.FunctionalityTab, 'numeric');
            app.StepEditField.ValueChangedFcn = createCallbackFcn(app, @StepEditFieldValueChanged, true);
            app.StepEditField.Position = [88 265 58 22];
            app.StepEditField.Value = 0.1;

            % Create DeltaKnobLabel
            app.DeltaKnobLabel = uilabel(app.FunctionalityTab);
            app.DeltaKnobLabel.HorizontalAlignment = 'center';
            app.DeltaKnobLabel.Position = [80 126 34 22];
            app.DeltaKnobLabel.Text = 'Delta';

            % Create DeltaKnob
            app.DeltaKnob = uiknob(app.FunctionalityTab, 'continuous');
            app.DeltaKnob.Limits = [0 10];
            app.DeltaKnob.ValueChangedFcn = createCallbackFcn(app, @DeltaKnobValueChanged, true);
            app.DeltaKnob.Position = [71 169 51 51];
            app.DeltaKnob.Value = 0.5;

            % Create AxisLimitsLabel
            app.AxisLimitsLabel = uilabel(app.FunctionalityTab);
            app.AxisLimitsLabel.HorizontalAlignment = 'right';
            app.AxisLimitsLabel.Position = [64 84 63 22];
            app.AxisLimitsLabel.Text = 'Axis Limits';

            % Create AxisLimitsSlider
            app.AxisLimitsSlider = uislider(app.FunctionalityTab);
            app.AxisLimitsSlider.Limits = [0.5 10.5];
            app.AxisLimitsSlider.Position = [20 73 150 3];
            app.AxisLimitsSlider.Value = 0.5;

            % Create TrailTab
            app.TrailTab = uitab(app.TabGroup);
            app.TrailTab.Title = 'Trail';

            % Create TrailSwitch
            app.TrailSwitch = uiswitch(app.TrailTab, 'slider');
            app.TrailSwitch.Items = {'No trail', 'Trail'};
            app.TrailSwitch.ValueChangedFcn = createCallbackFcn(app, @TrailSwitchValueChanged, true);
            app.TrailSwitch.Position = [80 266 45 20];
            app.TrailSwitch.Value = 'No trail';

            % Create LineStyleDropDownLabel
            app.LineStyleDropDownLabel = uilabel(app.TrailTab);
            app.LineStyleDropDownLabel.HorizontalAlignment = 'right';
            app.LineStyleDropDownLabel.Position = [7 206 58 22];
            app.LineStyleDropDownLabel.Text = 'Line Style';

            % Create TrailStyleDropDown
            app.TrailStyleDropDown = uidropdown(app.TrailTab);
            app.TrailStyleDropDown.ValueChangedFcn = createCallbackFcn(app, @TrailStyleDropDownValueChanged, true);
            app.TrailStyleDropDown.Position = [80 206 100 22];

            % Create TrailColorButton
            app.TrailColorButton = uibutton(app.TrailTab, 'push');
            app.TrailColorButton.ButtonPushedFcn = createCallbackFcn(app, @TrailColorButtonPushed, true);
            app.TrailColorButton.Position = [48 76 100 22];
            app.TrailColorButton.Text = 'Line Color';

            % Create LineWidthSpinnerLabel
            app.LineWidthSpinnerLabel = uilabel(app.TrailTab);
            app.LineWidthSpinnerLabel.HorizontalAlignment = 'right';
            app.LineWidthSpinnerLabel.Position = [22 138 62 22];
            app.LineWidthSpinnerLabel.Text = 'Line Width';

            % Create TrailWidthSpinner
            app.TrailWidthSpinner = uispinner(app.TrailTab);
            app.TrailWidthSpinner.Limits = [1 Inf];
            app.TrailWidthSpinner.ValueChangedFcn = createCallbackFcn(app, @TrailWidthSpinnerValueChanged, true);
            app.TrailWidthSpinner.Position = [99 138 66 22];
            app.TrailWidthSpinner.Value = 1;

            % Create ProbabilityDistributionTab
            app.ProbabilityDistributionTab = uitab(app.TabGroup);
            app.ProbabilityDistributionTab.Title = 'Probability Distribution';

            % Create DistributionTypeSwitch
            app.DistributionTypeSwitch = uiswitch(app.ProbabilityDistributionTab, 'rocker');
            app.DistributionTypeSwitch.Items = {'Continuous', 'Discrete'};
            app.DistributionTypeSwitch.Orientation = 'horizontal';
            app.DistributionTypeSwitch.ValueChangedFcn = createCallbackFcn(app, @DistributionTypeSwitchValueChanged, true);
            app.DistributionTypeSwitch.Position = [78 247 45 20];
            app.DistributionTypeSwitch.Value = 'Continuous';

            % Create NumberofDiscreteValuesKnobLabel
            app.NumberofDiscreteValuesKnobLabel = uilabel(app.ProbabilityDistributionTab);
            app.NumberofDiscreteValuesKnobLabel.HorizontalAlignment = 'center';
            app.NumberofDiscreteValuesKnobLabel.Position = [19 60 148 22];
            app.NumberofDiscreteValuesKnobLabel.Text = 'Number of Discrete Values';

            % Create DiscreteValuesKnob
            app.DiscreteValuesKnob = uiknob(app.ProbabilityDistributionTab, 'discrete');
            app.DiscreteValuesKnob.ValueChangedFcn = createCallbackFcn(app, @DiscreteValuesKnobValueChanged, true);
            app.DiscreteValuesKnob.Position = [62 97 60 60];

            % Create CurrentCoordinatesLabel
            app.CurrentCoordinatesLabel = uilabel(app.UIFigure);
            app.CurrentCoordinatesLabel.Position = [70 117 114 22];
            app.CurrentCoordinatesLabel.Text = 'Current Coordinates';

            % Create IterationTimesLabel
            app.IterationTimesLabel = uilabel(app.UIFigure);
            app.IterationTimesLabel.Position = [263 117 84 22];
            app.IterationTimesLabel.Text = 'Iteration Times';

            % Create IterationTimesEditField
            app.IterationTimesEditField = uieditfield(app.UIFigure, 'numeric');
            app.IterationTimesEditField.Editable = 'off';
            app.IterationTimesEditField.Position = [272 81 66 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = RandomWalkProject_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end