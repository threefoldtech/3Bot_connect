import time

from flask import request
from flask_socketio import SocketIO, leave_room, join_room, emit

import database as db
from services.logger import logger

sio = SocketIO(transports=["websocket"])

usersInRoom = {}
messageQueue = {}
socketRoom = {}


@sio.on("connect")
def on_connect():
    logger.debug("/Connect")


@sio.on("disconnect")
def on_disconnect():
    logger.debug("/disconnected.")
    if request.sid in socketRoom:
        room = socketRoom[request.sid].lower()
        logger.debug("User was disconnected, user was known {}".format(room))
        del socketRoom[request.sid]
        leave_room(room)
        if usersInRoom[room] > 0:
            usersInRoom[room] -= 1
            logger.debug(
                    "User was removed from room, users left in room {}".format(
                            usersInRoom[room]
                    )
            )


@sio.on("join")
def on_join(data):
    logger.debug("/Join %s", data)

    if data["room"] is None:
        return

    room = data["room"].lower()
    join_room(room)

    if "app" in data:
        socketRoom[request.sid] = room
        if not room in usersInRoom:
            usersInRoom[room] = 1
        else:
            usersInRoom[room] += 1
    if room in messageQueue:
        for message in messageQueue[room]:
            sio.emit(message[0], message[1], room=message[2])
        messageQueue[room] = []


@sio.on("leave")
def on_leave(data):
    logger.debug("/leave.")
    if request.sid in socketRoom:
        room = socketRoom[request.sid].lower()
        logger.debug("User left, user was known {}".format(room))
        del socketRoom[request.sid]
        leave_room(room)
        if usersInRoom[room] > 0:
            usersInRoom[room] -= 1
            logger.debug(
                    "User was removed from room, users left in room {}".format(
                            usersInRoom[room]
                    )
            )


@sio.on("checkname")
def on_checkname(data):
    logger.debug("/checkname %s", data)
    doublename = data.get("doubleName")
    user = db.get_user_by_double_name(doublename)

    if user:
        logger.debug("user %s", user["double_name"])
        emit("nameknown")
    else:
        logger.debug("user %s was not found", doublename)
        emit("namenotknown")


@sio.on("login")
def on_login(data):
    logger.debug("/login %s", data)
    double_name = data.get("doubleName")

    data["type"] = "login"
    milli_sec = int(round(time.time() * 1000))
    data["created"] = milli_sec

    user = db.get_user_by_double_name(double_name)
    if user:
        logger.debug("[login]: User found %s", user["double_name"])
        emitOrQueue("login", data, room=user["double_name"])


def emitOrQueue(event, data, room):
    logger.debug("Emit or queue data %s", data)
    if not room in usersInRoom or usersInRoom[room] == 0:
        logger.debug("Room is unknown or no users in room, so might queue for %s", room)
        if not room in messageQueue:
            logger.debug("Room is not known yet in queue, creating %s", room)
            messageQueue[room] = []
        logger.debug("Queueing in room %s", room)
        messageQueue[room].append((event, data, room))
    else:
        logger.debug("App is connected, sending to %s", room)
        sio.emit(event, data, room=room)
