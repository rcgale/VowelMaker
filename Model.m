classdef Model
    properties
        F0
        ModelStruct
    end

    properties (Access = private)
        NumSlices
    end
    
    methods
        function obj = Model(modelStruct, f0, numSlices)
            obj.F0 = f0;
            obj.ModelStruct = modelStruct;
            obj.NumSlices = numSlices;
        end
        
        function vowel = GetVowel(obj, vowelName)
            vowel = obj.ModelStruct.(vowelName);            
        end
        
        function vowelNames = GetVowelNames(obj)
            vowelNames = fieldnames(obj.ModelStruct);
        end
        
        % Play audio for a given vowel.
        function PlayVowel(obj, vowelName, len)
            vowel = obj.GetVowel(vowelName);
            [y, Fs] = vowel.GetSynthesizedVowel(obj.F0, len);
            soundsc(y, Fs);
            obj.ShowPlots(vowel, len, Fs);
        end
        
        % Plot the vowel (in real-time display)
        function ShowPlots(obj, vowel, len, Fs)
            for index = 1:obj.NumSlices
                toPlot = vowel.Filters(index,:);
                h = freqz(toPlot);
                freqAxis = linspace(0, Fs/2, length(toPlot) - 1);
                plot(freqAxis, 20*log10(abs(h)));
                axis([0 Fs/2 -40 40]);
                xlabel('Frequency (Hz)');
                ylabel('Magnitude (dB)');
            	pause(len/obj.NumSlices);
            end
        end        
    end
    
    methods (Static)
        % Parses a training file and training .wavs to make a Model of a
        % given voice set: [women, men, boys, girls] x numSlices x
        % threshold.
        function model = BuildModel(trainfile, group, numSlices, wavTrimAmplitudeThreshold)
            str='%s%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f%4.1f';
            [filenames,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = textread(trainfile, str);

            filenames = char(filenames);
            trimmedRawData = struct();

            for index = 1:length(filenames)
                file=[filenames(index,:) '.wav'];
                fileGroup = file(1:1);
                if (exist('group','var') && group ~= 'c' && fileGroup ~= group)
                    continue;
                end;
                vowelName = file(4:5);

                if ~isfield(trimmedRawData, vowelName)
                    trimmedRawData.(vowelName) = {};
                end;

                [y,Fs]=audioread(strcat('data/',file));
            
                y = Audio.TrimToVoiced(y, wavTrimAmplitudeThreshold);
                trimmedRawData.(vowelName) = vertcat(trimmedRawData.(vowelName), y);        
            end;

            modelStruct = struct();
            vowelNames = fieldnames(trimmedRawData);
            for index = 1:length(vowelNames)
                vowelName = char(vowelNames(index));
                vowelRawData = trimmedRawData.(vowelName);
                vowel = Vowel(vowelRawData, Fs, numSlices);
                modelStruct.(vowelName) = vowel;
            end;

            F0s = cellfun(@(x) Audio.GetF0(x, Fs), vowelRawData);
            meanF0 = mean(F0s);
            model = Model(modelStruct, meanF0, numSlices);
        end
    end
end
