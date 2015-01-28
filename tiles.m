function [] = tiles(varargin)
%Function that when called, will play a game of Don't Touch the White Tile,
%a popular game on the iPhone, but now you can play on your computer!!
%In this game, the user uses the arrow keys to step on the black tiles on a
%board of 4 rows of 3 tiles, in each row there is a black tile that the
%user is supposed to hit, if they accidentally hit one of the white ones,
%the game is over and they must start over.  To beat the game, you get 50
%black tiles in a row, and this game saves your highscore as a time, it is
%very additcting when you try to beat your score over and over again!

%Easily change the color of the background here, doesn't do much since we
%will populate it with patch objects later.
f_clr = [1 1 1];

%This value fluctuates back and forth from 0 to 1 based on 

S.lost = 0;
%Starting off the count at 0 which holds how far they have made it in the
%game
count = 0;
%This is where our high score is stored on the computer
SCR = load('TILES_HIGHSCORE.mat');
%The high score itself is in a variable called SCR, so this is how we
%access the current high score
S.currentHighScore = SCR.SCR;
%In order to try to prevent the board from having the same
%column black many times in a row, we will implement bayes rule
%so that the probability of the same row being chosen is much
%less than the probability of either of the other two being
%chosen
S.probNext3GivenPrev3 = .2;
S.probNext2GivenPrev2 = .2;
S.probNext1GivenPrev1 = .2;

S.probNext1GivenPrev2 = .4;
S.probNext1GivenPrev3 = .4;
S.probNext2GivenPrev1 = .4;
S.probNext2GivenPrev3 = .4;
S.probNext3GivenPrev1 = .4;
S.probNext3GivenPrev2 = .4;

S.probNext3 = 1/3;
S.probNext2 = 1/3;
S.probNext1 = 1/3;

S.probPrev1 = 1/3;
S.probPrev2 = 1/3;
S.probPrev3 = 1/3;

S.Bayes1 = S.probNext1GivenPrev1*S.probNext1/S.probPrev1;
S.Bayes2 = S.probNext2GivenPrev2*S.probNext2/S.probPrev2;
S.Bayes3 = S.probNext3GivenPrev3*S.probNext3/S.probPrev3;



%This sets the initial figure that will hold the axis and all the patch
%objects and text objects that are used to play the game. 
S.fig = figure('units','pixels',...
               'name','Dont Touch the White Tile',...
               'menubar','none',...
               'numbertitle','off',...
               'position',[100 100 500 750],...
               'color',f_clr,...
               'closereq',@fig_clsrqfcn,...
               'busyaction','cancel',...
               'renderer','opengl', ...
               'keypressfcn', @keypressfcn); %This specifies the key press function we will use
           %It allows us to use the keyboard to play the game

           
%In order to use patch objects, they must be written on an axis, this is
%the axis I will use to play the game.  
S.axs(1) = axes('units','pix',...
                'position',[30 30 360 650],...
                'ycolor','b',...
                'xcolor','b',...
                'xtick',[],'ytick',[],...
                'xlim',[-.1 6],...
                'ylim',[-.1 16],...
                'color','w',...
                'visible','on');



%These x and y matrices represent the vertices of each of the rectangle
%objects that 'move' when you press the buttons.  They are used to connect
%to each other in order to draw the patch object
x = [0 2 2 0; 2 4 4 2; 4 6 6 4];
y = [0 0 4 4; 4 4 8 8; 8 8 12 12; 12 12 16 16];


%Holds the handles of each of the tiles in the current view, we will refer
%to this every time we change the color of a tile, which is every time the
%user makes a move
S.pch = zeros(4,3);


%These two for loops will go through each of the x and y vectors in order
%to draw each of the vertices, the 'w' at the end specifies that their face
%color will be white
for j = 1:4
for i = 1:3
    S.pch(j,i) = patch(x(i,:),y(j,:),'w');
    
end
end


%This sets a random black tile for each of the rows in the figure, with one
%black tile in each row.  We simply randomely generate them using the randi
%built-in function which spits out an integer between 1 in 3 in this
%context.

r1 = randi(3);
r2 = randi(3);
r3 = randi(3);
r4 = randi(3);

%Here we will then use the set function to set one tiles in each row to
%black by changing its face color
set(S.pch(4,r1),'FaceColor','k');
set(S.pch(3,r2),'FaceColor','k');
set(S.pch(2,r3),'FaceColor','k');
set(S.pch(1,r4),'FaceColor','k');

%Text labeling the start tile appear before you start and disappears after
%the game is over, it will follow where the first black tile is.
S.startText = text(2*r4-1.3,2, 'Start','Color','y', 'FontSize', 20);

    %This is a function that is required if you want to close your figure
    %using the close button
    function [] = fig_clsrqfcn(varargin)  
        delete(varargin{1})
    end
    
    %This function is called every time the user presses the correct key to
    %correspond to the black tile.  It moves each of the top 3 rows down
    %and creates a new row at the top to simulate as if the user is
    %actually running on each tile
    function [] = movetiles(varargin)
        %Check if game is over or not
        if S.lost == 0
            %Check if we are on the first step
            if count == 0
                %begins the timer we use to calculate the time it takes to
                %get through the game
                tic; 
                %making the start text invisible 
                set(S.startText, 'visible', 'off');
            end
            
            %This for loop will set the three lower rows equal in color to
            %what the row above them was at the last time step
            for jj = 1:3
                for ii = 1:3
                    set(S.pch(jj,ii), 'FaceColor', get(S.pch(jj+1,ii), 'FaceColor'));

                end
            end
            
            %First we color all of the fourth row to white, and later we
            %will change one of the three tiles to black
            set(S.pch(4,1),'FaceColor', 'w');
            set(S.pch(4,2),'FaceColor', 'w');
            set(S.pch(4,3), 'FaceColor','w');
            
            
         
            %Below I will implement the bayes rule in order to help limit
            %the amount of tiles we see the same tile twice or more in a
            %row
            
            
            %This will give us a 3X3 matrix that has either 1 1 1 or 0 0 0
            %as its rows, this way we can determine which column has the
            %black tile in the 3rd row which determines the probability of
            %a tile showing up in different spots in the fourth row.
            
            color(1,:) = get(S.pch(3,1), 'FaceColor'); %Gives us 1 1 1 or 0 0 0
            color(2,:) = get(S.pch(3,2), 'FaceColor');
            color(3,:) = get(S.pch(3,3), 'FaceColor');
            
            %This is how we find which row has the 0 0 0 vector
            black = find(color==0);
            
            %Each of these corresponds to which column the black is in
            %because the find built in function returns a column vector
            black1 = [1;4;7];
            black2 = [2;5;8];
            black3 = [3;6;9];
            
            %Generate a random number between 1 and 10 so we can go through
            %and do different things based on what the number is
            randle = randi(10);
            
            %Based on our bayesian calculations above, there should be a .2
            %chance of the same tile coming in a row, so we will do this
            %when the random number is 1 or 2, then we will change one of
            %the other columns 8 out of 10 times, the method for doing this
            %is incorporated in the three if statements below
            %{
            if randle == 1 || randle == 2
                if isequal(black,black1)
                    set(S.pch(4,1),'FaceColor','k');
                elseif isequal(black,black2)
                    set(S.pch(4,2),'FaceColor','k');
                elseif isequal(black,black3)
                    set(S.pch(4,3),'FaceColor','k');

                end
            end
            %}
            if randle == 3 || randle ==4 || randle ==5 || randle == 6 || randle == 1
                if isequal(black,black1)
                    set(S.pch(4,3),'FaceColor','k');
                elseif isequal(black,black2)
                    set(S.pch(4,1),'FaceColor','k');
                elseif isequal(black,black3)
                    set(S.pch(4,2),'FaceColor','k');
                end
            end
            if randle == 7 || randle == 8 || randle == 9 || randle == 10 || randle == 2
                if isequal(black,black1)
                    set(S.pch(4,2),'FaceColor','k');
                elseif isequal(black,black2)
                    set(S.pch(4,3),'FaceColor','k');
                elseif isequal(black,black3)
                    set(S.pch(4,1),'FaceColor','k');
                end
            end
                
                
            
        end
    end
    
    %This function is called whenever the user wants to start a new game,
    %whether this be in the middle of a game or after they have lost, or
    %even before they begin
    function [] = startTiles(varargin)
        %Set the lost boolean to false so we know we can play
        S.lost = 0;
        %Restart the count so the player has to go through 50 new tiles to
        %win the game
        count = 0;
        
        %Set the whole board to white as we did at the beginning
        for j = 1:4
        for i = 1:3
              S.pch(j,i) = patch(x(i,:),y(j,:),'w');

        end
        end
        %Process for making the start Text visible in its right place, and
        %making exactly one tile in each row black
        r1 = randi(3);
        r2 = randi(3);
        r3 = randi(3);
        r4 = randi(3);
        set(S.pch(4,r1),'FaceColor','k');
        set(S.pch(3,r2),'FaceColor','k');
        set(S.pch(2,r3),'FaceColor','k');
        set(S.pch(1,r4),'FaceColor','k');
        S.startText = text(2*r4-1.3,2, 'Start','Color','y', 'FontSize', 20);
        set(S.startText, 'visible', 'on');
        
    end

    function [] = gameover(varargin)
       %This function is called whenever the user steps on the wrong tile,
       %it sets the lost boolean to true, displays the game over text and
       %the new game text 
       S.lost = 1;
       S.lostText = text(1,8,'Game Over','visible', 'on', 'FontSize', 40, 'Color', 'r');
       S.newGameText = text(1,6,'To Play a New Game, Press n','Color','b', 'FontSize', 18);
       
    end
    

    function [] = keypressfcn(varargin)
    %This important function determines what to do when different keys on the keyboard are pressed 
        
        %These will see what the colors are of each of the three tiles that
        %are on the lower row, or the playing row.
        leftcolor = get(S.pch(1,1), 'FaceColor');
        middlecolor = get(S.pch(1,2), 'FaceColor');
        rightcolor = get(S.pch(1,3), 'FaceColor');
        
        %This makes it so the user can start a new game whenever they want
        %by pressing 'n'
        if varargin{2}.Key == 'n'
                startTiles;   
        end
        
        %This check makes sure the game has not been lost or won, that the
        %user is in the middle of the game.
        if count < 50 && S.lost == 0
            
            %Making a switch case for the value of each key the interpreter
            %recieves
            switch varargin{2}.Key
            
                case 'leftarrow'
                    %If the left color is black, move the tiles and the
                    %count, if not, color the tile red and make the game
                    %over
                    if leftcolor == [0 0 0];
                        movetiles;
                        count = count + 1;
                        
                    else
                        set(S.pch(1,1),'FaceColor','r')
                        gameover;
                    end
                case 'rightarrow'
                    %If the right color is black, move the tiles and update the
                    %count, if not, color the tile red and make the game
                    %over
                    if rightcolor == [0 0 0];
                        movetiles;
                        count = count + 1;
                    
                    else
                        set(S.pch(1,3),'FaceColor','r')
                        gameover;
                    end

                case 'uparrow'
                    %If the middle color is black, move the tiles and update the
                    %count, if not, color the tile red and make the game
                    %over
                    if middlecolor == [0 0 0];
                        movetiles;
                        count = count + 1;
                    else
                        set(S.pch(1,2),'FaceColor','r')
                        gameover;
                    end
                    
            end
        else
        
            
        end
        %This call to play tiles will handle all of the cases when the user
        %is getting close to the finish and also handles what to do when
        %the user finishes
        playtiles;

    end
    

    function [] = playtiles(varargin)
        
        %The three if statements below bring the 'finish line' towards the
        %user when they get close to the 50 tiles
        if count == 47
            set(S.pch(4,1),'FaceColor', 'b');
            set(S.pch(4,2),'FaceColor', 'b');
            set(S.pch(4,3), 'FaceColor','b');
        end
        if count == 48
            set(S.pch(4,1),'FaceColor', 'b');
            set(S.pch(4,2),'FaceColor', 'b');
            set(S.pch(4,3), 'FaceColor','b');
        end
        if count == 49
            set(S.pch(4,1),'FaceColor', 'b');
            set(S.pch(4,2),'FaceColor', 'b');
            set(S.pch(4,3), 'FaceColor','b');
            set(S.pch(3,1),'FaceColor', 'b');
            set(S.pch(3,2),'FaceColor', 'b');
            set(S.pch(3,3), 'FaceColor','b');
        end
        
        %This if statement accounts for when the user has won the game and
        %gotten all 50 in a row. First we set the board to all blue to
        %represent the finish
        if count == 50
            %We stop the timer to see how fast the user completed the race
            S.completedTime = toc;
            set(S.pch(4,1),'FaceColor', 'b');
            set(S.pch(4,2),'FaceColor', 'b');
            set(S.pch(4,3), 'FaceColor','b');
            set(S.pch(3,1),'FaceColor', 'b');
            set(S.pch(3,2),'FaceColor', 'b');
            set(S.pch(3,3), 'FaceColor','b');
            set(S.pch(2,1),'FaceColor', 'b');
            set(S.pch(2,2),'FaceColor', 'b');
            set(S.pch(2,3), 'FaceColor','b');
            set(S.pch(1,1),'FaceColor', 'b');
            set(S.pch(1,2),'FaceColor', 'b');
            set(S.pch(1,3), 'FaceColor','b');
            
            %Switch this number to a string so it can be concatenated in
            %the text box we generate later
            S.score = num2str(S.completedTime);
            %Concatenate the strings 
            S.stringCat = strcat('Your Time: ',S.score);
            %Also create a string of the high score which is saved to the
            %computer
            S.highscoreString = num2str(S.currentHighScore);
            
            %Displays a text of the old high score every time the user
            %finishes
            S.highScoreText2 = text(1,7, strcat('Highscore:  ',S.highscoreString), 'Color', 'y','FontSize',30, 'visible','on');
            %Displayes the person's current score
            S.scoreText = text(1,8,S.stringCat,'Color','y', 'FontSize', 30);
            %Displays the new game text that prompts the user to press n to
            %start a new game.
            S.newGameText = text(1,6,'To Play a New Game, Press n','Color','y', 'FontSize', 18);
            
            %THis if statement handles if the user has beaten their high
            %score.
            if S.completedTime <= S.currentHighScore
                %If they do beat the high score, it updates with the new
                %high score
                set(S.highScoreText2, 'visible', 'off');
                SCR = S.completedTime;
                %Set the current score to the current high score so it can
                %be saved in the next line
                S.currentHighScore = S.completedTime;
                save('TILES_HIGHSCORE', 'SCR')
                %Display the two high score counts 
                S.highScoreText = text(1,9, 'New Highscore', 'FontSize', 36, 'Color', 'y');
                S.highScoreText2 = text(1,7, strcat('Highscore:  ',num2str(SCR)), 'Color', 'y','FontSize',30);
            end
            %Add one to the count so it doesn't remain at 50 if someone
            %presses a key
            count = count+1;
            
        end
        
    end
    
       
end
    

    
    

    
            
            
            
        
    

    