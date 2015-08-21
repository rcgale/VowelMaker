classdef Audio
    methods (Static)        
        % Trying to get something we can blend together for
        % stitching together sliced audio.
        function signal = TrimToPeriodic(segment, freq, Fs)
            period = Fs / freq;
            signal = segment;
        	last = round(length(signal) - mod(length(signal), period));
            signal = signal(1:last);
        end
        
        % Given a percentage threshold, trim audio to one peak
        % section 
        function [trimmed]=TrimToVoiced(signal, threshold)
            if (threshold == 0)
                trimmed = signal;
                return;
            end;
            [b0,a0]=butter(2,.002); 
            y = hilbert(signal); % Analyze signal
            env = filter(b0,a0,abs(y)); % Get slow-moving stuff (amplitude envelope)
            [peakValue, peakIndex] = max(env);
            env = env / peakValue; % normalize to 1

            startTrim = find(env(1:peakIndex) < threshold, 1, 'last');
            endTrim = peakIndex + find(env(peakIndex:end) < threshold, 1);
            trimmed = signal(startTrim:endTrim);
        end
        
        % Calculate the fundamental frequency of a signal.
        function f0=GetF0(x, Fs)
            maxSpeechFreq = Fs/500;
            minSpeechFreq = Fs/50;
            r=xcorr(x,minSpeechFreq,'coeff');   
            % just look at region corresponding to positive delays
            r=r(minSpeechFreq+1:2*minSpeechFreq+1);
            [~,tx]=max(r(maxSpeechFreq:minSpeechFreq));
            f0 = Fs/(maxSpeechFreq+tx-1);
        end
        
        % Get a spectral envelope of complexity numPoints, given a signal x.
        function [spectralEnvelope]=GetSpectralEnvelope(x, numPoints)
            len_x = length(x);
            w = hamming(len_x);
            wx = w .* x;

            % LPC autocorrelation method
            order = 20;
            [lpcoefs, ~] = lpc(wx, order);

            % The estimated signal is calculated as the output of linearly filtering
            % the speech signal with the coefficients estimated above.

            estx = filter([0 -lpcoefs(2:end)], 1, [wx; zeros(order, 1)]);

            % The prediction error is estimated in the interval 0 <= m <= N-1+p
            er = [wx; zeros(order, 1)] - estx;

            % Prediction error energy in the same interval 
            erEn = sum(er.^2);

            % Calculate the frequency response of the linear prediction model
            [H, ~] = freqz(sqrt(erEn), lpcoefs(1:end), numPoints);

            spectralEnvelope = 20*log10(abs(H))';
        end
   end
end