package com.designpatterns.structural.adapter;

import com.designpatterns.structural.adapter.impl.Mp4Player;
import com.designpatterns.structural.adapter.impl.VlcPlayer;
import com.designpatterns.structural.adapter.interfaces.AdvancedMediaPlayer;
import com.designpatterns.structural.adapter.interfaces.MediaPlayer;

public class MediaAdapter implements MediaPlayer {
	
	AdvancedMediaPlayer advancedMediaPlayer;

	
	
	public MediaAdapter(String audioType) {

		if(audioType.equalsIgnoreCase("vlc")) {
			advancedMediaPlayer = new VlcPlayer();
		} else if (audioType.equalsIgnoreCase("mp4")) {
			advancedMediaPlayer = new Mp4Player();
		}
	}

	@Override
	public void play(String audioType, String fileName) {
		
		if(audioType.equalsIgnoreCase("vlc")) {
			advancedMediaPlayer.playVlc(fileName);
		} else if (audioType.equalsIgnoreCase("mp4")) {
			advancedMediaPlayer.playMp4(fileName);
		}		
	}
}
