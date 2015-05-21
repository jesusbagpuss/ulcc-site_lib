# overrides for ULCC ffmpeg deployment
# $ rpm -q ffmpeg
# ffmpeg-0.10.15-1.el6.x86_64

# remove -vpre default, disambiguate -b, add -strict experimental
$c->{invocation}->{ffmpeg_video_mp4} = '$(ffmpeg) -y -i $(SOURCE) -acodec $(audio_codec) -ac 2 -ar $(audio_sampling) -ab $(audio_bitrate) -f $(container) -vcodec $(video_codec) -r $(video_frame_rate) -b:v $(video_bitrate) -s $(width)x$(height) -strict experimental $(TARGET)';

# disambiguate -b, add -strict experimental
$c->{invocation}->{ffmpeg_video_ogg} = '$(ffmpeg) -y -i $(SOURCE) -acodec $(audio_codec) -ac 2 -ar $(audio_sampling) -ab $(audio_bitrate) -f $(container) -vcodec $(video_codec) -r $(video_frame_rate) -b:v $(video_bitrate) -s $(width)x$(height) -strict experimental $(TARGET)';

# add -strict experimental
$c->{invocation}->{ffmpeg_audio_mp4} = '$(ffmpeg) -y -i $(SOURCE) -acodec $(audio_codec) -ac 2 -ar $(audio_sampling) -ab $(audio_bitrate) -f $(container) -strict experimental $(TARGET)';

# add -strict experimental
$c->{invocation}->{ffmpeg_audio_ogg} = '$(ffmpeg) -y -i $(SOURCE) -acodec $(audio_codec) -ac 2 -ar $(audio_sampling) -ab $(audio_bitrate) -f $(container) -strict experimental $(TARGET)';

# change libfaac to aac
$c->{plugins}->{"Convert::Thumbnails"}->{params}->{audio_mp4} = {
        audio_codec => "aac", # not libfaac
        audio_bitrate => "96k",
        audio_sampling => "44100",
        container => "mp4",
};
$c->{plugins}->{"Convert::Thumbnails"}->{params}->{video_mp4} = {
        audio_codec => "aac", # not libfaac
        audio_bitrate => "96k",
        audio_sampling => "44100",
        video_codec => "libx264",
        video_frame_rate => "10.00",
        video_bitrate => "500k",
        container => "mp4",
};
