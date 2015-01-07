package battlecode.client.viewer {
    import battlecode.client.viewer.render.DrawRobot;
    import battlecode.client.viewer.render.ImageAssets;
    import battlecode.client.viewer.render.RenderConfiguration;
    import battlecode.events.RobotEvent;

    import flash.events.Event;
    import flash.events.FullScreenEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;

    import mx.binding.utils.BindingUtils;
    import mx.binding.utils.ChangeWatcher;
    import mx.containers.HBox;
    import mx.containers.VBox;
    import mx.controls.Button;
    import mx.controls.HSlider;
    import mx.controls.Label;
    import mx.controls.Spacer;
    import mx.core.UITextField;
    import mx.events.FlexEvent;
    import mx.events.SliderEvent;

    public class ControlBar extends HBox {
        private var controller:MatchController;

        private var buttonBox:HBox;
        private var leftBox:VBox;
        private var startButton:Button;
        private var playButton:Button;
        private var fastForwardButton:Button;
        private var prevButton:Button;
        private var nextButton:Button;
        private var stepForwardButton:Button;
        private var stepBackwardButton:Button;
        private var fullscreenButton:Button;

        private var roundSlider:HSlider;
        private var roundLabel:Label;
        private var spacer:Spacer;
        private var versusField:Label;
        private var debugField1:UITextField;
        private var debugField2:UITextField;
        private var debugField3:UITextField;
        private var debugBox:VBox;
        private var savedPlayingState:Boolean;

        private var fpsLabel:Label;

        private var watchers:Vector.<ChangeWatcher>;

        private var selectedRobot:DrawRobot;

        public function ControlBar(controller:MatchController) {
            super();

            this.controller = controller;
            this.watchers = new Vector.<ChangeWatcher>();

            // set inital size
            percentWidth = 100;
            minHeight = 50;

            // set style
            setStyle("backgroundImage", ImageAssets.GRADIENT_BACKGROUND);
            setStyle("backgroundSize", "100%");
            setStyle("verticalAlign", "middle");

            leftBox = new VBox();
            addChild(leftBox);

            buttonBox = new HBox();
            buttonBox.percentWidth = 100;
            leftBox.addChild(buttonBox);

            // add versus label
            versusField = new Label();
            versusField.percentWidth = 100;
            versusField.setStyle("textAlign", "center");
            leftBox.addChild(versusField);

            // add buttons
            startButton = new Button();
            startButton.buttonMode = true;
            startButton.setStyle("icon", ImageAssets.START_ICON);
            buttonBox.addChild(startButton);

            playButton = new Button();
            playButton.buttonMode = true;
            playButton.setStyle("icon", ImageAssets.PLAY_ICON);
            buttonBox.addChild(playButton);

            fastForwardButton = new Button();
            fastForwardButton.buttonMode = true;
            fastForwardButton.setStyle("icon", ImageAssets.FASTFORWARD_ICON);
            buttonBox.addChild(fastForwardButton);

            prevButton = new Button();
            prevButton.buttonMode = true;
            prevButton.setStyle("icon", ImageAssets.PREVIOUS_ICON);
            buttonBox.addChild(prevButton);

            nextButton = new Button();
            nextButton.buttonMode = true;
            nextButton.setStyle("icon", ImageAssets.NEXT_ICON);
            buttonBox.addChild(nextButton);

            // add round slider
            roundSlider = new HSlider();
            roundSlider.buttonMode = true;
            roundSlider.allowTrackClick = false;
            roundSlider.minimum = 0;
            roundSlider.snapInterval = 1;
            roundSlider.width = 200;
            roundSlider.percentWidth = 100;
            roundSlider.dataTipFormatFunction = function (val:Number):String {
                return val.toString();
            }; // strip all formatting
            addChild(roundSlider);

            // add round label
            roundLabel = new Label();
            roundLabel.minWidth = 80;
            addChild(roundLabel);

            stepBackwardButton = new Button();
            stepBackwardButton.buttonMode = true;
            stepBackwardButton.setStyle("icon", ImageAssets.STEP_BACKWARD_ICON);
            addChild(stepBackwardButton);

            stepForwardButton = new Button();
            stepForwardButton.buttonMode = true;
            stepForwardButton.setStyle("icon", ImageAssets.STEP_FORWARD_ICON);
            addChild(stepForwardButton);

            fullscreenButton = new Button();
            fullscreenButton.buttonMode = true;
            fullscreenButton.setStyle("icon", ImageAssets.ENTER_FULLSCREEN_ICON);
            addChild(fullscreenButton);

            fpsLabel = new Label();
            fpsLabel.minWidth = 50;
            addChild(fpsLabel);

            debugBox = new VBox();
            debugBox.width = 200;
            debugBox.percentHeight = 100;
            debugBox.setStyle("verticalGap", 10);

            // only show debug box if not in tournament mode
            if (!RenderConfiguration.isTournament())
                addChild(debugBox);

            debugField1 = new UITextField();
            debugField2 = new UITextField();
            debugField3 = new UITextField();
            debugField1.percentWidth = 100;
            debugField2.percentWidth = 100;
            debugField3.percentWidth = 100;
            debugField1.autoSize = "left";
            debugField2.autoSize = "left";
            debugField3.autoSize = "left";
            debugBox.addChild(debugField1);
            debugBox.addChild(debugField2);
            debugBox.addChild(debugField3);

            // update bindings
            updateBindings();

            // add event listeners
            startButton.addEventListener(MouseEvent.CLICK, onStartButtonClick);
            playButton.addEventListener(MouseEvent.CLICK, onPlayButtonClick);
            fastForwardButton.addEventListener(MouseEvent.CLICK, onFastForwardButtonClick);
            prevButton.addEventListener(MouseEvent.CLICK, onPreviousButtonClick);
            nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClick);
            stepBackwardButton.addEventListener(MouseEvent.CLICK, onStepBackwardButtonClick);
            stepForwardButton.addEventListener(MouseEvent.CLICK, onStepForwardButtonClick);
            fullscreenButton.addEventListener(MouseEvent.CLICK, onFullscreenButtonClick);
            roundSlider.addEventListener(SliderEvent.CHANGE, onRoundSliderChange);
            roundSlider.addEventListener(SliderEvent.THUMB_PRESS, onRoundSliderThumbPress);
            roundSlider.addEventListener(SliderEvent.THUMB_RELEASE, onRoundSliderThumbRelease);

            addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
        }

        private function updateBindings():void {
            while (watchers.length > 0)
                watchers.pop().unwatch();

            // simple bindings
            addWatcher(BindingUtils.bindProperty(prevButton, "enabled", controller, "prevEnabled"));
            addWatcher(BindingUtils.bindProperty(nextButton, "enabled", controller, "nextEnabled"));
            addWatcher(BindingUtils.bindProperty(playButton, "selected", controller, "playing"));
            addWatcher(BindingUtils.bindProperty(fastForwardButton, "selected", controller, "fastForwarding"));
            addWatcher(BindingUtils.bindProperty(roundSlider, "value", controller, "currentRound"));

            // complex bindings
            addWatcher(ChangeWatcher.watch(controller, "playing", onPlayingChange));
            addWatcher(ChangeWatcher.watch(controller, "currentRound", onRoundChange));
            addWatcher(ChangeWatcher.watch(controller, "match", onMatchChange));
            addWatcher(ChangeWatcher.watch(controller, "fps", onFPSChange));
            addWatcher(ChangeWatcher.watch(controller, "selectedRobot", onSelectedRobotChange));

            // hack to update bindings
            updateRoundLabels();
            updateMatchInfoLabels();
            updateEnabledComponents();
            updateIndicatorStrings();
        }

        private function addWatcher(watcher:ChangeWatcher):void {
            watchers.push(watcher);
        }

        ///////////////////////////////////////////////////////
        ///////////// USER INTERACTION LISTENERS //////////////
        ///////////////////////////////////////////////////////

        private function onStartButtonClick(e:MouseEvent):void {
            controller.playing = false;
            controller.currentRound = 0;
        }

        private function onPlayButtonClick(e:MouseEvent):void {
            controller.playing = !controller.playing;
        }

        private function onFastForwardButtonClick(e:MouseEvent):void {
            controller.fastForwarding = !controller.fastForwarding;
        }

        private function onPreviousButtonClick(e:MouseEvent):void {
            controller.playing = false;
            controller.currentMatch--;
        }

        private function onNextButtonClick(e:MouseEvent):void {
            controller.playing = false;
            controller.currentMatch++;
        }

        private function onStepBackwardButtonClick(e:MouseEvent):void {
            controller.currentRound--;
        }

        private function onStepForwardButtonClick(e:MouseEvent):void {
            controller.currentRound++;
        }

        private function onFullscreenButtonClick(e:MouseEvent):void {
            //stage.displayState = stage.displayState == "fullScreen" ? "normal" : "fullScreen";
            if (stage.fullScreenSourceRect) {
                stage.fullScreenSourceRect = null;
                stage.displayState = "normal";
            } else {
                stage.fullScreenSourceRect = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
                stage.displayState = "fullScreen";
            }
        }

        private function onRoundSliderChange(e:SliderEvent):void {
            controller.currentRound = roundSlider.value;
        }

        private function onRoundSliderThumbPress(e:SliderEvent):void {
            savedPlayingState = controller.playing;
            controller.playing = false;
        }

        private function onRoundSliderThumbRelease(e:SliderEvent):void {
            controller.playing = savedPlayingState;
        }

        private function onIndicatorStringChange(e:RobotEvent):void {
            updateIndicatorStrings();
        }

        private function onCreationComplete(e:FlexEvent):void {
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
        }

        private function onFullScreen(e:FullScreenEvent):void {
            fullscreenButton.setStyle("icon", (e.fullScreen) ?
                    ImageAssets.EXIT_FULLSCREEN_ICON : ImageAssets.ENTER_FULLSCREEN_ICON);
            if (e.fullScreen) {
                e.target.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, int.MAX_VALUE, true);
                e.target.addEventListener(Event.ENTER_FRAME, onEnterNextFrame);
            }
        }

        ///////////////////////////////////////////////////////
        ////////////// COMPLEX BINDING HANDLERS ///////////////
        ///////////////////////////////////////////////////////

        private function onPlayingChange(e:Event):void {
            playButton.setStyle("icon", (controller.playing) ? ImageAssets.PAUSE_ICON : ImageAssets.PLAY_ICON);
            stepBackwardButton.enabled = !controller.playing;
            stepForwardButton.enabled = !controller.playing;
        }

        private function onRoundChange(e:Event):void {
            updateRoundLabels();
        }

        private function onMatchChange(e:Event):void {
            updateRoundLabels();
            updateMatchInfoLabels();
            updateEnabledComponents();
        }

        private function onFPSChange(e:Event):void {
            updateFPSLabel();
        }

        private function onSelectedRobotChange(e:Event):void {
            if (selectedRobot && !selectedRobot.parent) {
                updateIndicatorStrings();
            }

            if (selectedRobot == controller.selectedRobot)
                return;

            if (selectedRobot)
                selectedRobot.removeEventListener(RobotEvent.INDICATOR_STRING_CHANGE, onIndicatorStringChange);

            selectedRobot = controller.selectedRobot;
            if (selectedRobot)
                selectedRobot.addEventListener(RobotEvent.INDICATOR_STRING_CHANGE, onIndicatorStringChange);

            updateIndicatorStrings();
        }

        private function onDisplayStateChange(e:Event):void {
            fullscreenButton.setStyle("icon", (stage.displayState == "normal") ?
                    ImageAssets.ENTER_FULLSCREEN_ICON : ImageAssets.EXIT_FULLSCREEN_ICON);
        }

        ///////////////////////////////////////////////////////
        ////////////////// HELPER METHODS /////////////////////
        ///////////////////////////////////////////////////////

        private function updateRoundLabels():void {
            if (controller.match) {
                roundLabel.text = controller.currentRound + " of " + Math.max(controller.match.getMaxRounds(), controller.match.getRounds());
            }
        }

        private function updateMatchInfoLabels():void {
            if (controller.match) {
                roundSlider.tickValues = [ controller.match.getRounds() ];
                roundSlider.maximum = Math.max(controller.match.getMaxRounds(), controller.match.getRounds());
                versusField.text = controller.match.getTeamA() + " vs. " + controller.match.getTeamB() + " on " + controller.match.getMapName();
            }
        }

        private function updateEnabledComponents():void {
            var enableComponents:Boolean = controller.match != null;

            startButton.enabled = enableComponents;
            playButton.enabled = enableComponents;
            fastForwardButton.enabled = enableComponents;
            roundSlider.enabled = enableComponents;
        }

        private function updateFPSLabel():void {
            fpsLabel.text = controller.fps + " fps";
        }

        private function updateIndicatorStrings():void {
            if (selectedRobot && selectedRobot.parent && !RenderConfiguration.isTournament()) {
                debugField1.text = selectedRobot.getIndicatorString(0);
                debugField2.text = selectedRobot.getIndicatorString(1);
                debugField3.text = selectedRobot.getIndicatorString(2);
            } else {
                debugField1.text = "";
                debugField2.text = "";
                debugField3.text = "";
            }
        }

        //
        // Handle Spacebar Keypress Bug
        //

        private function onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.SPACE)
                e.stopImmediatePropagation();
        }

        private function onEnterNextFrame(e:Event):void {
            e.target.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            e.target.removeEventListener(Event.ENTER_FRAME, onEnterNextFrame);
        }

    }

}