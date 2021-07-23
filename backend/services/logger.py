import logging

logger = logging.getLogger(__name__)

logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()
formatter = logging.Formatter(
        "[%(asctime)s][%(lineno)s - %(funcName)s()]: %(message)s", "%Y-%m-%d %H:%M:%S"
)

handler.setFormatter(formatter)
logger.addHandler(handler)
