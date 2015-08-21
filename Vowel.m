classdef Vowel
    properties
        Filters
        Fs
    end
    
    properties (Access = private)
        clickFilter
    end
    
    methods
        % Constructor
        function obj = Vowel(vowelRawData, Fs, numFilters)
            obj.Fs = Fs;
            obj.Filters = Vowel.GetFilters(vowelRawData, numFilters);
            obj.clickFilter = fir2(100, [0 0.4 0.6 1], [1 1 0 0]);
        end
       
        % Generates a synthesized vowel given a freq, length, and the
        % object's filters.
        function [signal, Fs] = GetSynthesizedVowel(obj, freq, len)
            signal = [];
            Fs = obj.Fs;
            [numFilters, ~] = size(obj.Filters);
            % A vowel can be rendered by configurable number of slices,
            % imitating some change over time.
            for index = 1:numFilters
                formantFilter = obj.Filters(index,:);
                segment = obj.GetFilteredSignal(formantFilter, freq, len/numFilters);
                segment = Audio.TrimToPeriodic(segment, freq, Fs);
                signal = [signal, segment];
            end
            signal = filter(obj.clickFilter, 1, signal);
        end
    end
    
    methods (Access = private)
        % This is the heart of the source-filter theory work. The source is
        % a sawtooth oscillator with a little noise mixed in. The filters
        % are provided by the training model.
        function [filteredSignal, Fs] = GetFilteredSignal(obj, filter, freq, len)
            Fs = obj.Fs;
            sawSource = sawtooth(2 * pi * freq * (1:Fs*len) / Fs);
            noiseSource = randn(1, length(sawSource)); 
            source = sawSource + (0.05 * noiseSource);
            filteredSignal = conv(source, filter, 'same');            
        end    
    end
    
    methods (Static, Access = private)
        
        % Get average spectral filters for (numFilters) segments of
        % given raw data.
        function filters = GetFilters(vowelRawData, numFilters)
            complexity = 513;
            filters = zeros(numFilters, complexity);
            for index = 1:numFilters
                sliceEnvelopes = cell2mat(cellfun(@(x) Vowel.getSliceEnvelope(x, index, numFilters, complexity), vowelRawData, 'UniformOutput', false));
                env = mean(sliceEnvelopes);
                mag = 10.^(env/20);
                freq = linspace(0,1,complexity);
                filter = fir2(512, freq, mag);
                filters(index,:) = filter;
            end;
        end
        
        % Get the average envelope for a given slice of a sound signal.
        function env = getSliceEnvelope(sound, whichSlice, numSlices, complexity)
            slicePoints = linspace(1,length(sound),numSlices+1);
            slice = sound(floor(slicePoints(whichSlice)):ceil(slicePoints(whichSlice+1)));
            env = Audio.GetSpectralEnvelope(slice, complexity);
        end
    end
end