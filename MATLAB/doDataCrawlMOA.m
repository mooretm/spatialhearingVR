function [Y] = doDataCrawlMOA(condNum,verbose)

folderList = dir('Travis_Dissertation');
numFolders = length(folderList);

Y = []; % dimension an empty matrix to hold values

if verbose == 1
    fprintf('\n\nPulling data...\n')
end

for files = 3:numFolders % start at 3 to avoid the '.' and '..'
    fileName = folderList(files).name;
    
    if verbose == 1
        fprintf('\nSubject: %s\n', fileName)
    end
    
    myPath = ['Travis_Dissertation/', fileName, '/'];
    load([myPath, fileName '.mat']);

    x = size(data.condition(condNum).trials(:,:,:));
    if x(1) > 0 && numel(x) == 2 % single row/block
        z = data.condition(condNum).trials(:,:,:);
        %z = z(any(z,2),:); % removes 0s and NANs
        z = z(any(z ~= 0,2),:); % leaves NANs and removes only 0s
        Y = [Y;z];
        if verbose == 1
            fprintf('Condition: %s\n',data.key{condNum});
            fprintf('Blocks found: 1\n');
        end
    elseif x(1) > 0 && numel(x) == 3 % multiple rows/blocks
        for blocks = 1:x(3);
        z = data.condition(condNum).trials(:,:,blocks);
        %z = z(any(z,2),:); % removes 0s and NANs
        z = z(any(z ~= 0,2),:); % leaves NANs and removes only 0s
        Y = [Y;z];
        end
        if verbose == 1
            fprintf('Condition: %s\n',data.key{condNum});
            fprintf('Blocks found: %d\n',x(3));
        end
    end
end

% save data to txt file
if ~isempty(Y)
    
    if verbose == 1
        fprintf('\nWriting to disk...\n')
    end
    
    % write output to file
    myFile = sprintf('Condition_%d.txt', condNum);
    dlmwrite(myFile,Y,'delimiter','\t');
end

if verbose == 1
    fprintf('\nFinished successfully\nGoodbye!\n\n');
end
