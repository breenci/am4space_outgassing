function fn_struct = parse_filename(fn, mode)
% PARSE_FILENAME Extract measurement information from filename
%   fn_struct = PARSE_FILENAME(fn, mode) extracts info from filename string
% (fn) and returns a structure cotaining the relevent information.
% 
% Can operate on a sample file (mode = "sample") or a background file
% (mode = "background).

% split the filename to extract information
info_arr = split(fn, '_');


% create the datetime object
datetime_str = strcat(info_arr(1), info_arr(2));
datetime_fmt = 'yyyyMMddHHmmss';
meas_datetime = datetime(datetime_str, "Format", datetime_fmt);

if mode == "sample"
    % create a structure for the sample info
    sample_info = split(info_arr(3), '-');
    sample_struct = struct('name', sample_info(1), 'id', ...
        str2double(sample_info(2)), 'shape', sample_info(3));
    
    % create a structure to store all of the information
    fn_struct = struct('datetime', meas_datetime, 'operator', info_arr(4), ...
        'sample', sample_struct);
elseif mode == "background"
    fn_struct = struct('datetime', meas_datetime, 'operator', info_arr(4), ...
        'sample', info_arr(3));
end
end